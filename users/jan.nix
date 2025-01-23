# How Jan likes his linux to be configured

{ config, pkgs, ... }:

{
  config = {
    # State version
    home.stateVersion = "24.05";

    # TODO: Move into modules
    home.packages = with pkgs; [
      libreoffice-still
      remmina
      # dina-vector
      # android-studio
      # jellyfin-tui
      pinentry
      thunderbird
      signal-desktop
      prusa-slicer
      freecad-wayland
      # appflowy
    ];

    # TODO: Move to gpg module
    programs.gpg = {
      enable = true;
      mutableKeys = true;
      mutableTrust = true;
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    # Enabled modules
    modules = {
      # Theming
      theming.enable = true;

      # Window manager
      river.enable = true;
      waylock.enable = true;
      waybar.enable = true;
      glpaper.enable = false;

      # Desktop environment
      mako.enable = true;
      foot.enable = true;

      # Communication
      whatsapp.enable = true;
      discord.enable = true;

      # Browser
      firefox = {
        enable = true;
        default = true;
      };
      qutebrowser = {
        enable = true;
        default = false;
      };

      # Gaming
      steam.enable = true;
      modrinth.enable = true;

      # Media
      spotify.enable = true;
      feishin.enable = false;

      # Tools
      rofi-rbw.enable = true;
      git = {
        enable = true;
        user = "Jan-Bulthuis";
        email = "git@bulthuis.dev";
      };
      btop.enable = true;
      fish.enable = true;
      bluetuith.enable = false;
      winbox.enable = true;
      obsidian.enable = true;
      zathura.enable = true;

      # Development
      neovim.enable = true;
      vscode.enable = true;
      docker.enable = true;

      # Languages
      haskell.enable = false;
      js.enable = true;
      nix.enable = true;
      rust.enable = true;
      python.enable = true;
      cpp.enable = true;
      tex.enable = true;
      jupyter.enable = true;

      # Enable unfree
      unfree.enable = true;
    };

    # Theme configuration
    theming =
      let
        fontpkgs = config.theming.fonts.pkgs;
      in
      {
        # Fonts
        fonts.serif = fontpkgs."DejaVu Serif";
        fonts.sansSerif = fontpkgs."DejaVu Sans";
        fonts.monospace = fontpkgs."Dina";
        fonts.emoji = fontpkgs."Noto Color Emoji";
        fonts.extraFonts = [ ];

        # Color scheme
        themes.oxocarbon = {
          enable = false;
          darkMode = false;
        };
        themes.catppuccin = {
          enable = true;
          flavor = "mocha";
        };
        themes.sakura.enable = false;
        themes.nord = {
          enable = false;
          darkMode = true;
        };
      };

    # TODO: Remove everything below, it is here out of convenience and should be elsewhere
    xdg.portal = {
      enable = true;

      config.common.default = [
        "wlr"
        "gtk"
      ];

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };
  };
}
