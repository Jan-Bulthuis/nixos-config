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
    users.users.mixer = {
      group = "mixer";
    };
    users.groups.mixer = { };

    # Spotifyd service
    systemd.user.services.spotifyd = {
      description = "SpotifyD Service";
      wantedBy = [ "default.target" ];
      after = [
        "network.target"
        "sound.target"
      ];
      unitConfig = {
        ConditionUser = "mixer"; # TODO: Allow user configuration
      };
      serviceConfig = {
        ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path /etc/spotifyd/spotifyd.conf";
        Restart = "always";
        RestartSec = 5;
      };
    };

    # Set up config
    environment.etc = {
      "spotifyd/spotifyd.conf" = {
        source = ./spotifyd.conf;
        mode = "0444";
        user = "mixer"; # TODO: Make user configurable
        group = "mixer";
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
