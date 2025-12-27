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
    ];
    disable = [
      # "coredns" # CoreDNS is required for Flux to be able to bootstrap the cluster (Flux needs to resolve the git repo)
      # "servicelb" # Required for Traefik, can later be replaced with load balancer deployed through Flux
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
      "0-secrets-backup-namespaces" = {
        source = "/opt/k3s-secrets-backup/namespaces.yaml";
      };
      "1-secrets-backup" = {
        source = "/opt/k3s-secrets-backup/secrets.yaml";
      };
    };
    autoDeployCharts = {
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
  };

  environment.systemPackages = with pkgs; [
    fluxcd
    k9s
  ];

  # Use correct disko profile
  modules.disko.profile = "k3s";

  # TEMP: Disable firewall for now
  networking.firewall.enable = false;
  security.sudo.wheelNeedsPassword = false;
}
