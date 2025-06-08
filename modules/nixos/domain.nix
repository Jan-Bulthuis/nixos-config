{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.domain;
  domain = inputs.secrets.lab.domain;
  domainUpper = lib.strings.toUpper domain;
in
{
  options.modules.domain = {
    enable = mkEnableOption "Domain Integration";
    join = {
      userFile = mkOption {
        type = types.str;
        description = "File containing the user used to join the computer.";
      };
      passwordFile = mkOption {
        type = types.str;
        description = "File containing the password for the join user.";
      };
      domainOUFile = mkOption {
        type = types.str;
        description = "The OU to join the computer to.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Set network domain
    networking.domain = domain;
    networking.search = [ domain ];

    # Automatically join the domain
    systemd.services.adcli-join = {
      description = "Automatically join the domain";
      wantedBy = [ "default.target" ];
      after = [
        "network.target"
      ];
      serviceConfig = {
        type = "oneshot";
      };
      script = ''
        ADCLI_JOIN_USER=$(cat ${cfg.join.userFile})
        ADCLI_JOIN_OU=$(cat ${cfg.join.domainOUFile})
        ${pkgs.adcli}/bin/adcli join -D ${domain} \
          -U $ADCLI_JOIN_USER \
          -O $ADCLI_JOIN_OU < ${cfg.join.passwordFile}
      '';
    };
  };
}
