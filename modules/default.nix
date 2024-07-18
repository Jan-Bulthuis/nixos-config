{ lib, config, pkgs, ... }:

with lib; {
  imports = [
    # Import modules
    ./greeter/greetd/default.nix
    ./greeter/greetd/tuigreet.nix
    ./locale/default.nix
    ./neovim/default.nix
    ./sound/pipewire.nix
    ./users/default.nix
    ./unfree/default.nix
    ./vpn/tailscale.nix
    ./wifi/wpa_supplicant.nix
  ];

  config.modules = {
    # Enable default modules
    neovim.enable = mkDefault true;
    tuigreet.enable = mkDefault true;
    tailscale.enable = mkDefault true;
  };
}