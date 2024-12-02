# Dotfiles

My NixOS configuration.

## Usage

Clone the repository to some directory. `/etc/nixos/git` in this example.

Set up `configuration.nix`:
```nix
{ ... }:

{
    imports = [
        ./hardware-configuration.nix
        ./git/machines/[machine].nix
    ];
}
```