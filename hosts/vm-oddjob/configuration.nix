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
  systemd.services.mnt-nas-krb5 = {
    description = "Set up Kerberos credentials for mnt-nas";
    before = [ "mnt-nas.mount" ];
    requiredBy = [ "mnt-nas.mount" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      . ${config.sops.secrets."smb-credentials".path}
      echo $password | ${pkgs.krb5}/bin/kinit $username
    '';
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
              mount /mnt/${share}
              ${pkgs.util-linux}/bin/prlimit --nofile=1024:1024 ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client backup nfs.pxar:/mnt/${share} --ns $PBS_NAMESPACE --backup-id share-${share} --change-detection-mode=metadata --exclude "#recycle"
              umount /mnt/${share}
            '') inputs.secrets.lab.nas.backupShares
          )
        );
      in
      [
        "0 0 * * * root ${script}"
      ];
  };

  # Mount filesystems

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
