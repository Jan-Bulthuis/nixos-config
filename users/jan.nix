# How Jan likes his linux to be configured

{ ... }:

{
  imports = [
    ./janMerged.nix
  ];

  config = {
    # State version
    home.stateVersion = "24.05";

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
      winbox.enable = true;
      discord.enable = true;

      # Enable unfree
      unfree.enable = true;
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
