# Dotfiles

My NixOS configuration.

## Installation

For disk configuration we use disko, but for secrets management we use sops-nix and the particular setup makes the installation process a bit more involved. It is required that the computer from which the installation is being run has access to the `nixos-secrets` repository, otherwise you will need to manually add the required ssh keys to the installation image. 
```bash
# Load into the installer
sudo passwd # Set a root password

# From a machine with network access to the installer
# and access to the nixos-secrets repo
ssh -A root@(installer-ip)

# Set up disks
nix-shell -p disko
disko --mode disko --flake git+https://git.bulthuis.dev/Jan/nixos-config#(system)
exit

# Install NixOS
nixos-install --no-channel-copy --no-root-password --flake git+https://git.bulthuis.dev/Jan/nixos-config#(system)

# Set up host credentials for access to the secrets
cd /mnt/persist/system/etc/sops
touch sops_ed25519_key 
chmod 600 sops_ed25519_key
nano sops_ed25519_key
```
If `nixos-install` is being stopped by the OOM-killer, you can try adding `-j 1` to limit the amount of jobs that will be executed at the same time to 1. It might require running nixos-install multiple times untill it has managed to download all requirements and slowly start building the rest of the system.

## Updating

To update the system configuration, it is a single command:
```bash
sudo system-update
```
Or if this shell script has not been installed for some reason:
```bash
sudo nixos-rebuild switch --flake git+https://git.bulthuis.dev/Jan/nixos-config
```
Sometimes it may be necessary to reboot of course.