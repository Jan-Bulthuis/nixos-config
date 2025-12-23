{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.gnome;
in
{
  options.modules.gnome = {
    enable = mkEnableOption "gnome";
    # TODO: Add RDP toggle
  };

  config = mkIf cfg.enable {
    # Enable GDM and Gnome
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.gnome.core-apps.enable = false;
    services.gnome.games.enable = false;
    services.gnome.core-developer-tools.enable = false;
    environment.gnome.excludePackages = with pkgs; [
      adwaita-icon-theme
      (derivation { name = "nixos-background-info"; })
      gnome-backgrounds
      gnome-bluetooth
      gnome-color-manager
      gnome-shell-extensions
      gnome-tour
      gnome-user-docs
      glib
      gnome-menus
      gtk3.out
    ];

    # For GSConnect/KDE Connect
    # TODO: Move to host config?
    networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };

    # Enable dependencies
    modules.networkmanager.enable = true;

    # Impermanence
    modules.impermanence.directories = [ "/etc/NetworkManager/system-connections" ];
  };
}
