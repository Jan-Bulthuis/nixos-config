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
  environment.systemPackages = with pkgs; [ cifs-utils ];
  sops.secrets."smb-credentials" = {
    sopsFile = "${inputs.secrets}/secrets/vm-oddjob.enc.yaml";
  };
  fileSystems."/mnt/nas" = {
    device = "//${inputs.secrets.lab.nas.host}/Backup";
    fsType = "cifs";
    options = [ "sec=krb5,credentials=${config.sops.secrets."smb-credentials".path}" ];
  };
}
