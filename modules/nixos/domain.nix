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
        "network-online.target"
      ];
      requires = [
        "network-online.target"
      ];
      serviceConfig = {
        type = "oneshot";
      };
      script = ''
        ADCLI_JOIN_USER=$(cat ${cfg.join.userFile})
        ADCLI_JOIN_OU=$(cat ${cfg.join.domainOUFile})
        ${pkgs.adcli}/bin/adcli join -D ${domain} \
          -U $ADCLI_JOIN_USER \
          -O $ADCLI_JOIN_OU \
          --stdin-password < ${cfg.join.passwordFile}
      '';
    };

    # Set up SSSD
    services.sssd = {
      enable = true;
      config = ''
        [sssd]
        domains = ${domain}
        config_file_version = 2
        services = nss, pam, ssh

        [domain/${domain}]
        enumerate = false
        ad_domain = ${domain}
        krb5_realm = ${domainUpper}
        id_provider = ad
        auth_provider = ad
        access_provider = ad
        chpass_provider = ad
        use_fully_qualified_names = false
        ldap_id_mapping = true
        ad_gpo_access_control = permissive
        dyndns_update = true
        dyndns_refresh_interval = 3600
        dyndns_update_ptr = true
        dyndns_ttl = 3600
      '';
    };
    systemd.services.sssd = {
      after = [ "adcli-join.service" ];
      requires = [ "adcli-join.service" ];
    };
  };
}
