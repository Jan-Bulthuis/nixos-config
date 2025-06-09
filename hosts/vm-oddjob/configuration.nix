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
  environment.etc."request-key.conf".text =
    let
      upcall = "${pkgs.cifs-utils}/bin/cifs.upcall";
      keyctl = "${pkgs.keyutils}/bin/keyctl";
    in
    ''
      #OP    TYPE         DESCRIPTION  CALLOUT_INFO PROGRAM
      # -t is required for DFS share servers...
      create cifs.spnego  *            *            ${upcall} -t %k
      create dns_resolver *            *            ${upcall} %k
      # Everything below this is essentially the
      # defualt configuration
      create user         debug:*      negate       ${keyctl} negate %k 30 %S
      create user         debug:*      rejected     ${keyctl} reject %k 30 %c %S
      create user         debug:*      expired      ${keyctl} reject %k 30 %c %S
      create user         debug:*      revoked      ${keyctl} reject %k 30 %c %S
      create user         debug:loop:* *            |${pkgs.coreutils}/bin/cat
      create user         debug:*      *            ${pkgs.keyutils}/share/keyutils/request-key-debug.sh %k %d %c %S
      negate *            *            *            ${keyctl} negate %k 30 %S
    '';
  sops.secrets."smb-credentials" = {
    sopsFile = "${inputs.secrets}/secrets/vm-oddjob.enc.yaml";
  };
  systemd.services.mnt-nas-krb5 = {
    description = "Set up Kerberos credentials for mnt-nas";
    before = [ "mnt-nas.mount" ];
    requiredBy = [ "mnt-nas.mount" ];
    serviceConfig.type = "oneshot";
    script = ''
      . ${config.sops.secrets."smb-credentials".path}
      echo $password | kinit $username
    '';
  };
  fileSystems."/mnt/nas" = {
    device = "//${inputs.secrets.lab.nas.host}/Backup";
    fsType = "cifs";
    options = [ "sec=krb5,credentials=${config.sops.secrets."smb-credentials".path}" ];
  };
}
