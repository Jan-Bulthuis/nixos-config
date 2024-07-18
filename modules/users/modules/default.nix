{ input, pkgs, config, ... }:

{
  # Set the state version
  home.stateVersion = "24.05";
  
  imports = [
    # Import all modules
    ./desktop/default.nix
    ./feishin/default.nix
    ./firefox/default.nix
    ./obsidian/default.nix
    ./shell/bash.nix
    ./shell/fish.nix
    ./theming/default.nix
    ./vscode/default.nix
    ./zathura/default.nix
  ];
}
