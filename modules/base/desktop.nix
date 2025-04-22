{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.base.desktop;
in
{
  options.modules.base.desktop = {
    enable = mkEnableOption "desktop";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # TODO: MOVE
      quickemu # TODO: Reenable once building this is fixed
      pdftk

      # TODO: Move to USB module
      # usbutils
      # udiskie
      # udisks
      brightnessctl

      wireshark
    ];

    # Move to Realm module
    security.krb5 = {
      enable = true;
      settings = {
        libdefaults = {
          rdns = false;
        };
        realms = {
          "GEWISWG.GEWIS.NL" = {
            kdc = [
              "https://gewisvdesktop.gewis.nl/KdcProxy"
            ];
          };
        };
      };
    };

    modules = {
      # Enable base modules
      base.enable = true;
      fontconfig.enable = true;
      nixgreety.enable = true;
      pipewire.enable = true;
      graphics.enable = true;
    };

    programs.dconf.enable = true;
    services.libinput.enable = true;
    networking.firewall = {
      enable = mkForce false;
      logRefusedConnections = true;
      logRefusedPackets = true;
      logReversePathDrops = true;
      logRefusedUnicastsOnly = false;
    };
    programs.wireshark.enable = true;
    machine.sudo-groups = [ "wireshark" ];
    services.upower.enable = true; # For battery percentage in gnome
    modules.unfree.allowedPackages = [
      "nvidia-x11"
      "nvidia-settings"
    ];
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 10000;
        to = 11000;
      }
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 10000;
        to = 11000;
      }
    ];
    security.rtkit.enable = true;

    # TODO: Move to USB module
    # services.gvfs.enable = true;
    services.udisks2.enable = true;
  };
}
