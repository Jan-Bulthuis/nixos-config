{
  input,
  pkgs,
  config,
  ...
}:

{
  imports = [
    # Import all modules
    ./browser/default.nix
    ./desktop/default.nix
    ./discord/default.nix
    ./feishin/default.nix
    ./fontconfig/default.nix
    ./language/nix.nix
    ./language/rust.nix
    ./mako/default.nix
    ./neovim/default.nix
    ./obsidian/default.nix
    ./rofi/default.nix
    ./rofi/rofi-rbw.nix
    ./shell/bash.nix
    ./shell/fish.nix
    ./steam/default.nix
    ./terminal/default.nix
    ./terminal/foot/default.nix
    ./theming/default.nix
    ./vscode/default.nix
    ./winbox/default.nix
    ./zathura/default.nix

    # Import unfree helper
    ../../unfree/default.nix
  ];
}
