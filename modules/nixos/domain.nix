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

    # Set up Kerberos
    security.krb5 = {
      enable = true;
      settings = {
        libdefaults = {
          default_realm = domainUpper;
        };
        realms.${domainUpper} = {
        };
        domain_realm = {
          "${domain}" = domainUpper;
          ".${domain}" = domainUpper;
        };
      };
    };

    # Set up SSSD
    services.sssd = {
      enable = true;
      sshAuthorizedKeysIntegration = true;
      config = ''
        [sssd]
        domains = ${domain}
        config_file_version = 2
        services = nss, pam, ssh

        [nss]
        filter_users = ${concatStringsSep "," (lib.attrNames config.users.users)}
        filter_groups = ${concatStringsSep "," (lib.attrNames config.users.groups)}

        [domain/${domain}]
        enumerate = False
        ad_domain = ${domain}
        krb5_realm = ${domainUpper}H
        id_provider = ad
        auth_provider = ad
        access_provider = ad
        chpass_provider = ad
        use_fully_qualified_names = False
        ldap_schema = ad
        ldap_id_mapping = True
        ad_gpo_access_control = enforcing
        ad_gpo_implicit_deny = True
        dyndns_update = true
        dyndns_refresh_interval = 3600
        dyndns_update_ptr = false
        dyndns_ttl = 3600
        ldap_user_extra_attrs = altSecurityIdentities:altSecurityIdentities
        ldap_user_ssh_public_key = altSecurityIdentities
      '';
    };
    systemd.services.sssd = {
      after = [ "adcli-join.service" ];
      requires = [ "adcli-join.service" ];
    };
    security.pam.services.login.sssdStrictAccess = true;
    security.pam.services.sshd.sssdStrictAccess = true;

    # Set up Sudo
    security.sudo =
      let
        admin_group = (lib.replaceStrings [ "-" ] [ "_" ] config.networking.hostName) + "_admin";
      in
      {
        extraConfig = ''
          %${admin_group} ALL=(ALL) SETENV: ALL
        '';
      };

    # Set up home directory
    security.pam.services.login.makeHomeDir = true;
    security.pam.services.sshd.makeHomeDir = true;
    environment.etc.profile.text =
      let
        # TODO: Activate configuration based on AD group
        homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (
              { lib, ... }:
              {
                home.stateVersion = "24.11";
                home.username = "$USER";
                home.homeDirectory = "/.$HOME";
                modules.profiles.base.enable = true;

                # Mount the directories from the network share
                home.activation.dirMount = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  if ${pkgs.krb5}/bin/klist -s; then
                    echo "Kerberos ticket found, mounting home directory"
                    ln -s /network/$USER/Documents $HOME/Documents || true
                    ln -s /network/$USER/Music $HOME/Music || true
                    ln -s /network/$USER/Pictures $HOME/Pictures || true
                    ln -s /network/$USER/Video $HOME/Video || true
                  else
                    echo "No kerberos ticket found"
                  fi
                '';
              }
            )
          ] ++ config.home-manager.sharedModules;
        };
      in
      mkAfter ''
        # Activate Home Manager configuration for domain users
        if id | egrep -o 'groups=.*' | sed 's/,/\n/g' | cut -d'(' -f2 | sed 's/)//' | egrep -o "^domain users$"; then
          echo "Setting up environment for domain user"
          SKIP_SANITY_CHECKS=1 ${homeConfiguration.activationPackage}/activate
          . $HOME/.bashrc
        fi
      '';

    # Automatically mount home share
    # Can be accessed at /network/$USER
    services.autofs = {
      enable = true;
      autoMaster =
        let
          networkMap = pkgs.writeText "auto" ''
            * -fstype=cifs,sec=krb5,user=&,uid=$UID,gid=$GID,cruid=$UID ://${inputs.secrets.lab.nas.host}/home
          '';
        in
        ''
          /network ${networkMap} --timeout=30
        '';
    };
  };
}
