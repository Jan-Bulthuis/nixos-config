{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
{
  imports = [
    # Import modules
    ./base/default.nix
    ./bluetooth/default.nix
    ./boot/clean-tmp.nix
    ./boot/silent-boot.nix
    ./boot/systemd-boot.nix
    ./brightnessctl/default.nix
    ./fontconfig/default.nix
    ./graphics/default.nix
    ./greeter/greetd/default.nix
    ./greeter/greetd/nixgreety.nix
    ./greeter/greetd/tuigreet.nix
    ./greeter/ly/default.nix
    ./locale/default.nix
    ./neovim/default.nix
    ./networkmanager/default.nix
    ./power-saving/default.nix
    ./sound/pipewire.nix
    ./users/default.nix
    ./unfree/default.nix
    ./vpn/tailscale.nix
    ./wifi/wpa_supplicant.nix
  ];
}
