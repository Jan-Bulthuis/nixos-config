# Dotfiles

My NixOS configuration.

## Installation

For disk configuration we use disko, this means that installing the system from the configuration is just a single command:

```
sudo nix --experimental-features "nix-command flakes" run "github:nix-community/disko/latest#disko-install" -- --flake git+https://git.bulthuis.dev/Jan/dotfiles#<hostname> --disk main /dev/sda
```