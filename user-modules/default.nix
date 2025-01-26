{
  ...
}:

{
  imports = [
    # Import all modules
    ./bluetuith/default.nix
    ./browser/default.nix
    ./btop/default.nix
    ./desktop/default.nix
    ./development/default.nix
    ./discord/default.nix
    ./feishin/default.nix
    ./fontconfig/default.nix
    ./gaming/default.nix
    ./git/default.nix
    ./mako/default.nix
    ./neovim/default.nix
    ./obsidian/default.nix
    ./rofi/default.nix
    ./rofi/rofi-rbw.nix
    ./shell/default.nix
    ./shell/bash.nix
    ./shell/fish.nix
    ./spotify/default.nix
    ./terminal/default.nix
    ./terminal/foot/default.nix
    ./theming/default.nix
    ./vscode/default.nix
    ./whatsapp/default.nix
    ./winbox/default.nix
    ./zathura/default.nix

    # Import unfree helper
    ../modules/unfree/default.nix
  ];
}
