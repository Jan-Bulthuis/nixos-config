{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.profiles.gnome;
in
{
  options.modules.profiles.gnome = {
    enable = mkEnableOption "Graphical GNOME environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # firefox # TODO: Move to dediated module
    ];

    dconf.settings = {
      "org/gnome/calendar" = {
        active-view = "week";
      };
      "org/gnome/desktop/background" = {
        picture-uri = "file://${config.home.homeDirectory}/.local/share/backgrounds/background";
      };
      "org/gnome/desktop/input-sources" = {
        sources = [
          (lib.gvariant.mkTuple [
            "xkb"
            "us"
          ])
        ];
        xkb-options = [ "caps:escape_shifted_capslock" ];
      };
      "org/gnome/desktop/interface" = {
        accent-color = "purple";
        enable-hot-corners = false;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        speed = 0.214;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/mutter" = {
        workspaces-only-on-primary = false;
      };
      "org/gnome/nautilus/icon-view" = {
        default-zoom-level = "small";
      };
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "icon-view";
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = false;
        night-light-schedule-from = 20.0;
        night-light-schedule-to = 6.0;
        night-light-temperature = 2700;
      };
      "org/gnome/shell" = {
        disable-extension-version-validation = true;
        enabled-extensions = [
          "disable-workspace-animation@ethnarque"
          "gsconnect@andyholmes.github.io"
          "rounded-window-corners@fxgn"
          "media-progress@krypion17"
          "mprisLabel@moon-0xff.github.com"
        ];
        last-selected-power-profile = "power-saver";
      };
    };

    modules = {
      profiles.base.enable = true;

      # Desktop environment
      desktop.gnome.enable = true;
      # desktop.tiling.enable = true;

      # Browser
      # firefox = {
      #   enable = true;
      #   default = false;
      # };
      # qutebrowser = {
      #   enable = true;
      #   default = true;
      # };

      # Tools
      # obsidian.enable = true;
      # zathura.enable = true;

      # Development
      # neovim.enable = true;
      vscode.enable = true;
    };
  };
}
