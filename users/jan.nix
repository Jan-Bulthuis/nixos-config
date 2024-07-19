# How Jan likes his linux to be configured

{ config, ... }:

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
      qutebrowser.enable = true;
      neovim.enable = true;

      # Programming languages
      nix.enable = true;
      rust.enable = true;

      # Enable unfree
      unfree.enable = true;
    };

    # Theme configuration
    theming = let fontpkgs = config.theming.fonts.pkgs; in {
      # Fonts
      fonts.serif = fontpkgs."DejaVu Serif";
      fonts.sansSerif = fontpkgs."DejaVu Sans";
      fonts.monospace = fontpkgs."Dina";
      fonts.emoji = fontpkgs."Dina";
      fonts.extraFonts = [];
      
      # Color scheme
      themes.catppuccin = {
        enable = true;
        flavor = "frappe";
      };
    };
  };
}
