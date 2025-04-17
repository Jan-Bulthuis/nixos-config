{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.spotifyd;
in
{
  options.modules.spotifyd = {
    enable = mkEnableOption "spotifyd";
  };

  config = mkIf cfg.enable {
    # User for spotifyd
    users.users.spotifyd = {
      isSystemUser = true;
      group = "spotifyd";
    };
    users.groups.spotifyd = { };

    # Spotifyd service
    systemd.services.spotifyd = {
      description = "Spotifyd Service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "sound.target"
      ];
      serviceConfig = {
        ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path /etc/spotifyd/spotifyd.conf";
        Restart = "always";
        RestartSec = 5;
        User = "spotifyd";
        Group = "spotifyd";
      };
    };

    # Set up config
    environment.etc = {
      "spotifyd/spotifyd.conf" = {
        source = ./spotifyd.conf;
        mode = "0444";
        user = "spotifyd";
        group = "spotifyd";
      };
    };

    # Set up firewall
    networking.firewall = {
      allowedTCPPorts = [
        5353
        5454
      ];
      allowedUDPPorts = [
        5353
        5454
      ];
    };
  };
}
