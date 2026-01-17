{
  inputs,
  pkgs,
  config,
  ...
}:

{
  # State version
  system.stateVersion = "25.05";

  # Machine hostname
  networking.hostName = "vm-k1s";

  # Enabled modules
  modules = {
    profiles.vm.enable = true;
  };

  # Read in secrets
  sops.secrets."flux/git-ssh-key" = {
    sopsFile = "${inputs.secrets}/secrets/k3s-cluster.enc.yaml";
  };
  sops.secrets."flux/sops-decrypt-key" = {
    sopsFile = "${inputs.secrets}/secrets/k3s-cluster.enc.yaml";
  };

  # Include NFS client module
  boot.supportedFilesystems = [ "nfs" ];

  # Set up K3S cluster with CoreDNS and FluxCD
  services.k3s = {
    enable = true;
    extraFlags = [
      "--cluster-domain ${inputs.secrets.lab.k3s.clusterDomain}"
      "--flannel-backend=none"
      "--disable-network-policy"
      "--disable-kube-proxy"
    ];
    disable = [
      # "coredns" # CoreDNS is required for Flux to be able to bootstrap the cluster (Flux needs to resolve the git repo)
      "servicelb"
      "traefik"
      "local-storage"
      "metrics-server"
      "runtimes"
    ];
    manifests = {
      git-ssh-key = {
        source = config.sops.secrets."flux/git-ssh-key".path;
      };
      sops-decrypt-key = {
        source = config.sops.secrets."flux/sops-decrypt-key".path;
      };
      # "0-secrets-backup-namespaces" = {
      #   source = "/opt/k3s-secrets-backup/namespaces.yaml";
      # };
      # "1-secrets-backup" = {
      #   source = "/opt/k3s-secrets-backup/secrets.yaml";
      # };
      # TODO: Move to flux config, once it is possible to easily install flux without CNI
      cilium-secrets-namespace = {
        content = {
          apiVersion = "v1";
          kind = "Namespace";
          metadata.name = "cilium-secrets";
        };
      };
      # TODO: Move to flux config, once it is possible to easily install flux without CNI
      gateway-api =
        let
          manifest = pkgs.fetchurl {
            url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/experimental-install.yaml";
            hash = "sha256-08IN1MBDGTZWemkXypMfbc7RMQJCvmK57KB72YkuICU=";
          };
        in
        {
          source = manifest;
        };
      # TODO: Move to flux config, once it is possible to easily install flux without CNI
      netpol-system-allow-egress.content = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumClusterwideNetworkPolicy";
        metadata.name = "allow-system-egress";
        spec = {
          description = "Allow all egress to system services.";
          endpointSelector = {
            matchExpressions = [
              {
                key = "io.kubernetes.pod.namespace";
                operator = "NotIn";
                values = [
                  "bogus-namespace"
                  # "kube-system"
                  # "cilium-system"
                  # "flux-system"
                ];
              }
            ];
          };
          egress = [
            {
              toEntities = [
                "all"
              ];
            }
          ];
          ingress = [
            {
              fromEntities = [
                "all"
              ];
            }
          ];
        };
      };
      netpol-cluster-allow-dns.content = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumClusterwideNetworkPolicy";
        metadata.name = "allow-dns";
        spec = {
          description = "Allow DNS";
          endpointSelector = { };
          egress = [
            {
              toEndpoints = [
                {
                  matchLabels = {
                    "io.kubernetes.pod.namespace" = "kube-system";
                    "k8s-app" = "kube-dns";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = 53;
                      protocol = "ANY";
                    }
                  ];
                  rules.dns = [
                    {
                      matchPattern = "*";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
      netpol-flux-allow-egress.content = { };
    };
    autoDeployCharts = {
      # TODO: Move to flux config, once it is possible to easily install flux without CNI
      cilium = {
        name = "cilium";
        repo = "oci://quay.io/cilium/charts/cilium";
        version = "1.18.6";
        hash = "sha256-+yr38lc5X1+eXCFE/rq/K0m4g/IiNFJHuhB+Nu24eUs=";
        createNamespace = true;
        targetNamespace = "cilium-system";
        values = {
          operator.replicas = 1;
          kubeProxyReplacement = true;
          ipam.operator.clusterPoolIPv4PodCIDRList = [ "10.42.0.0/16" ];
          cluster = {
            id = 1;
            name = "vm-k1s";
          };
          k8sServiceHost = "10.10.50.60";
          k8sServicePort = 6443;
          policyEnforcementMode = "always";
          gatewayAPI = {
            enabled = true;
            gatewayClass.create = "true";
            secretsNamespace.create = false;
            enableAlpn = true;
          };
          bgpControlPlane.enabled = true;
          tls.secretsNamespace.create = false;
          hubble = {
            relay.enabled = true;
            ui.enabled = true;
            peerService.clusterDomain = inputs.secrets.lab.k3s.clusterDomain;
          };
        };
        extraFieldDefinitions = {
          spec.bootstrap = true;
        };
      };
      flux-operator = {
        name = "flux-operator";
        repo = "oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator";
        version = "0.38.1";
        hash = "sha256-nb0mzEWC3IwjPenQ4LSWBN0NNJc2cc68RB+G60xBOEM=";
        createNamespace = true;
        targetNamespace = "flux-system";
        extraDeploy = [
          {
            apiVersion = "fluxcd.controlplane.io/v1";
            kind = "FluxInstance";
            metadata = {
              name = "flux";
              namespace = "flux-system";
              annotations = {
                "fluxcd.controlplane.io/reconcile" = "enabled";
                "fluxcd.controlplane.io/reconcileEvery" = "1h";
                "fluxcd.controlplane.io/reconcileTimeout" = "5m";
              };
            };
            spec = {
              distribution = {
                version = "2.x";
                registry = "ghcr.io/fluxcd";
              };
              components = [
                "source-controller"
                "kustomize-controller"
                "helm-controller"
                "notification-controller"
              ];
              cluster = {
                type = "kubernetes";
                size = "small";
                multitenant = false;
                networkPolicy = true;
                domain = inputs.secrets.lab.k3s.clusterDomain;
              };
              commonMetadata.labels = {
                "app.kubernetes.io/name" = "flux";
              };
              sync = (
                {
                  pullSecret = "git-ssh-key";
                }
                // inputs.secrets.lab.k3s.fluxRepo
              );
            };
          }
        ];
      };
    };
  };

  # Backup secrets to avoid reissueing them
  modules.impermanence.directories = [
    "/opt/k3s-secrets-backup"
  ];
  systemd.timers.k3s-secrets-backup-timer = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "1h";
      Unit = "k3s-secrets-backup.service";
    };
  };
  systemd.services.k3s-secrets-backup = {
    script = ''
      mkdir -p /opt/k3s-secrets-backup
      touch /opt/k3s-secrets-backup/secrets.yaml
      touch /opt/k3s-secrets-backup/namespaces.yaml
      chmod 600 /opt/k3s-secrets-backup/secrets.yaml
      chmod 600 /opt/k3s-secrets-backup/namespaces.yaml

      ${pkgs.k3s}/bin/kubectl get secrets -A -l controller.cert-manager\.io/fao=="true" -oyaml | ${pkgs.kubectl-neat}/bin/kubectl-neat > /opt/k3s-secrets-backup/secrets.yaml

      echo "apiVersion: v1
      kind: List
      items:" > /opt/k3s-secrets-backup/namespaces.yaml

      ${pkgs.gnugrep}/bin/grep -oP '\snamespace: \K.*' /opt/k3s-secrets-backup/secrets.yaml | sort -u | while read -r ns; do
        echo "- apiVersion: v1
        kind: Namespace
        metadata:
          name: $ns"
      done >> /opt/k3s-secrets-backup/namespaces.yaml
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  environment.variables = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    CILIUM_NAMESPACE = "cilium-system";
  };

  environment.systemPackages = with pkgs; [
    fluxcd
    k9s
    cilium-cli
    hubble
  ];

  # Use correct disko profile
  modules.disko.profile = "k3s";

  # TEMP: Disable firewall for now
  networking.firewall.enable = false;
  security.sudo.wheelNeedsPassword = false;
}
