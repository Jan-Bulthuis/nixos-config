{ input, pkgs, config, ... }:

{ 
  imports = [
    # Import all modules
    ./desktop/default.nix
    ./discord/default.nix
    ./feishin/default.nix
    ./firefox/default.nix
    ./fontconfig/default.nix
    ./obsidian/default.nix
    ./shell/bash.nix
    ./shell/fish.nix
    ./steam/default.nix
    ./theming/default.nix
    ./vscode/default.nix
    ./winbox/default.nix
    ./zathura/default.nix

    # Import unfree helper
    ../../unfree/default.nix
  ];
}
