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
    cifs-utils
    keyutils
    samba
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
  # systemd.services.mnt-nas-krb5 = {
  #   description = "Set up Kerberos credentials for mnt-nas";
  #   before = [ "mnt-nas.mount" ];
  #   requiredBy = [ "mnt-nas.mount" ];
  #   serviceConfig.type = "oneshot";
  #   script = ''
  #     . ${config.sops.secrets."smb-credentials".path}
  #     echo $password | ${pkgs.krb5}/bin/kinit $username
  #   '';
  # };
  fileSystems."/mnt/nas" = {
    device = "//${inputs.secrets.lab.nas.host}/Backup";
    fsType = "cifs";
    options = [ "sec=krb5,credentials=${config.sops.secrets."smb-credentials".path}" ];
  };
}
