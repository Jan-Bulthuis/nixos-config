# Dotfiles

My NixOS configuration.

## Installation

For disk configuration we use disko, this means that installing the system can be done with the following commands:
```
nix-shell -p disko
sudo disko --mode disko --flake git+https://git.bulthuis.dev/Jan/dotfiles#<system>
sudo nixos-install --no-channel-copy --no-root-password --flake git+https://git.bulthuis.dev/Jan/dotfiles#<system>
```
If `nixos-install` is being stopped by the OOM-killer, you can try adding `-j 1` to limit the amount of jobs that will be executed at the same time to 1. It might require running nixos-install multiple times untill it has managed to download all requirements and slowly start building the rest of the system.

## Updating

To update the system configuration, it is a single command:
```
sudo system-update
```
Or if this shell script has not been installed for some reason:
```
sudo nixos-rebuild switch --flake git+https://git.bulthuis.dev/Jan/dotfiles
```
Sometimes it may be necessary to reboot of course.