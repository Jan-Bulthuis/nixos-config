{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.desktop.gnome;
in
{
  options.modules.desktop.gnome = {
    enable = mkEnableOption "gnome";
  };

  config = mkIf cfg.enable {
    # TODO: Enable extensions with dconf

    home.pointerCursor = {
      name = "capitaine-cursors";
      size = 24;
      package = pkgs.capitaine-cursors;
      gtk.enable = true;
      x11.enable = true;
    };

    home.packages =
      with pkgs;
      [
        gnome-session
        gnome-shell
        gnome-tweaks
        gnome-calculator
        snapshot
        gnome-characters
        gnome-connections
        blackbox-terminal
        baobab
        gnome-disk-utility
        evince
        nautilus
        gnome-font-viewer
        loupe
        gnome-maps
        gnome-music
        gnome-control-center
        gnome-text-editor
        showtime
        file-roller
        mission-center
        dconf-editor

        # For theming gtk3
        adw-gtk3
      ]
      ++ (with pkgs.gnomeExtensions; [
        gsconnect
        disable-workspace-animation
        wallpaper-slideshow
        media-progress
      ]);

    # Enable and set the gtk themes
    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-theme-name = "adw-gtk3";
      };
      gtk4.extraConfig = {
        gtk-theme-name = "Adwaita";
      };
    };

    # Set the theme with dconf
    dconf.settings."org/gnome/desktop/interface" = {
      gtk-theme = "adw-gtk3";
    };
  };
}
