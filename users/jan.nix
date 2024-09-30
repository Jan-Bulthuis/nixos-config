# How Jan likes his linux to be configured

{ config, pkgs, ... }:

{
  config = {
    # State version
    home.stateVersion = "24.05";

    # TODO: Move into modules
    home.packages = with pkgs; [ libreoffice-fresh ];

    # Enabled modules
    modules = {
      # Window manager
      river.enable = true;
      waylock.enable = true;
      waybar.enable = true;
      glpaper.enable = true;

      # Theming
      theming.enable = true;

      # Programs
      feishin.enable = true;
      firefox.enable = true;
      foot.enable = true;
      mako.enable = true;
      vscode.enable = true;
      zathura.enable = true;
      fish.enable = true;
      whatsapp.enable = true;
      winbox.enable = true;
      discord.enable = true;
      qutebrowser = {
        enable = true;
        default = true;
      };
      neovim.enable = true;
      rofi-rbw.enable = true;
      obsidian.enable = true;
      bluetuith.enable = true;

      # Programming languages
      haskell.enable = true;
      nix.enable = true;
      rust.enable = true;

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
        fonts.emoji = fontpkgs."Dina";
        fonts.extraFonts = [ ];

        # Color scheme
        themes.oxocarbon = {
          enable = false;
          darkMode = false;
        };
        themes.catppuccin = {
          enable = false;
          flavor = "mocha";
        };
        themes.sakura.enable = true;

        # TODO: Remove
        # Nice themes:
        # - rose-pine-dawn: Decent, bit too yellow though.
        # - sagelight: Barely readable
        # - danqing-light: Too minty
        # - fruit-soda: Colors too bright, background too dark.
        # - solarflare-light: Nice
        # darkMode = false;
        # colorScheme = "${pkgs.base16-schemes}/share/themes/solarflare-light.yaml";
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
