{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:

{
  # State version
  system.stateVersion = "24.11";

  # Machine hostname
  networking.hostName = "vm-oddjob";

  # Enabled modules
  modules = {
    profiles.vm.enable = true;
  };

  # Omada Software Controller
  users.users.omada = {
    isSystemUser = true;
    group = "omada";
  };
  users.groups.omada = { };
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      omada-controller = {
        volumes = [
          "/var/lib/omada:/opt/tplink/EAPController/data"
          "/var/log/omada:/opt/tplink/EAPController/logs"
        ];
        environment = {
          TZ = "Europe/Amsterdam";
        };
        extraOptions = [
          "--network=host"
          "--ulimit"
          "nofile=4096:8192"
        ];
        image = "mbentley/omada-controller:5.15";
      };
    };
  };
  modules.impermanence.directories = [
    "/var/lib/omada"
    "/var/log/omada"
  ];
  networking.firewall = {
    allowedTCPPorts = [
      8088
      8043
      8843
    ];
    allowedTCPPortRanges = [
      {
        from = 29811;
        to = 29816;
      }
    ];
    allowedUDPPorts = [
      19810
      27001
      29810
    ];
  };

  # Setup NAS backups
  environment.systemPackages = with pkgs; [
    keyutils
  ];
  environment.etc."request-key.d/cifs.spnego.conf".text = ''
    create cifs.spnego * * ${pkgs.cifs-utils}/bin/cifs.upcall -t %k
  '';
  environment.etc."request-key.d/cifs.idmap.conf".text = ''
    create cifs.idmap * * ${pkgs.cifs-utils}/bin/cifs.idmap %k
  '';
  sops.secrets."smb-credentials" = {
    sopsFile = "${inputs.secrets}/secrets/vm-oddjob.enc.yaml";
  };
  sops.secrets."backup-script-env" = {
    sopsFile = "${inputs.secrets}/secrets/vm-oddjob.enc.yaml";
  };
  services.cron = {
    enable = true;
    systemCronJobs =
      let
        script = pkgs.writeShellScript "backup-script" (
          lib.concatStrings (
            [
              ''
                . ${config.sops.secrets."backup-script-env".path}
                export PBS_REPOSITORY=$PBS_REPOSITORY
                export PBS_NAMESPACE=$PBS_NAMESPACE
                export PBS_PASSWORD=$PBS_PASSWORD
                export PBS_FINGERPRINT=$PBS_FINGERPRINT
              ''
            ]
            ++ lib.map (share: ''
              systemctl start mnt-${share}.mount
              ${pkgs.util-linux}/bin/prlimit --nofile=1024:1024 ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client backup nfs.pxar:/mnt/${share} --ns $PBS_NAMESPACE --backup-id share-${share} --change-detection-mode=metadata --exclude "#recycle"
              systemctl stop mnt-${share}.mount
            '') inputs.secrets.lab.nas.backupShares
          )
        );
      in
      [
        "0 0 * * * root ${script}"
      ];
  };

  # Mount filesystems
  systemd.services.krb5-mnt-credentials = {
    description = "Set up Kerberos credentials for mounting shares";
    before = map (share: "mnt-${share}.mount") inputs.secrets.lab.nas.backupShares;
    requiredBy = map (share: "mnt-${share}.mount") inputs.secrets.lab.nas.backupShares;
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      . ${config.sops.secrets."smb-credentials".path}
      echo $password | ${pkgs.krb5}/bin/kinit $username
    '';
  };
  fileSystems = lib.listToAttrs (
    lib.map (share: {
      name = "/mnt/${share}";
      value = {
        device = "//${inputs.secrets.lab.nas.host}/${share}";
        fsType = "cifs";
        options = [
          "noauto"
          "sec=krb5,credentials=${config.sops.secrets."smb-credentials".path}"
        ];
      };
    }) inputs.secrets.lab.nas.backupShares
  );
}
