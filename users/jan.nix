# How Jan likes his linux to be configured

{ config, pkgs, ... }:

{
  config = {
    # State version
    home.stateVersion = "24.05";

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
      winbox.enable = true;
      discord.enable = true;
      qutebrowser = {
        enable = true;
        default = true;
      };
      neovim.enable = true;
      rofi-rbw.enable = true;

      # Programming languages
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
        themes.catppuccin = {
          enable = false;
          flavor = "latte";
        };
        themes.sakura.enable = true;
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
