# How Jan likes his linux to be configured

{ ... }:

{
  imports = [
    ./janMerged.nix
  ];

  config = {
    # State version
    home.stateVersion = "24.05";

    # Allow unfree software such as vscode
    nixpkgs.config.allowUnfree = true;

    modules = {
      # Window manager
      river.enable = true;
      waylock.enable = true;

      # Programs
      feishin.enable = true;
      firefox.enable = true;
      vscode.enable = true;
      zathura.enable = true;
      fish.enable = true;
    };

    theming.themes.gruvbox = {
      enable = false;
      darkMode = false;
      contrast = "hard";
    };

    theming.themes.catppuccin = {
      enable = true;
      flavor = "latte";
    };
  };
}
