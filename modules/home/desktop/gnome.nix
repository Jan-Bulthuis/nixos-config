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
    # TODO: Enable extensions (declaratively) with dconf

    home.pointerCursor = {
      enable = true;
      name = "capitaine-cursors";
      size = 24;
      package = pkgs.capitaine-cursors;
      gtk.enable = true;
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
        papers
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
        gnome-calendar

        # For theming gtk3
        # adw-gtk3 # TODO: Do this better, same for morewaita, not sure if it even works

        # More icons
        # morewaita-icon-theme
      ]
      ++ (with pkgs.gnomeExtensions; [
        gsconnect
        disable-workspace-animation
        wallpaper-slideshow
        media-progress
        mpris-label
        pip-on-top
        rounded-window-corners-reborn
      ]);

    # Set up gnome terminal as changing the default terminal is a pain
    programs.gnome-terminal = {
      enable = true;
      profile."12d2da79-b36c-43d5-8e1f-cf70907b84b3" = {
        visibleName = "Default";
        default = true;
      };
    };

    # Enable and set the gtk themes
    # gtk = {
    #   enable = true;
    #   gtk3.extraConfig = {
    #     gtk-theme-name = "adw-gtk3";
    #   };
    #   gtk4.extraConfig = {
    #     gtk-theme-name = "Adwaita";
    #   };
    # };

    # Set the theme with dconf
    # dconf.settings."org/gnome/desktop/interface" = {
    #   gtk-theme = "adw-gtk3";
    # };
  };
}
