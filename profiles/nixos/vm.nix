{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.profiles.vm;
in
{
  options.modules.profiles.vm = {
    enable = mkEnableOption "Base VM profile";
  };

  config = mkIf cfg.enable {
    # Enabled modules
    modules = {
      profiles.base.enable = true;
      disko = {
        enable = true;
        profile = "vm";
      };
      impermanence = {
        enable = true;
        resetScript = ''
          # Revert to the blank state for the root directory
          zfs rollback -r tank/root@blank
        '';
      };
      domain = {
        enable = true;
        join = {
          userFile = config.sops.secrets."vm-join/user".path;
          passwordFile = config.sops.secrets."vm-join/password".path;
          domainOUFile = config.sops.secrets."vm-join/ou".path;
        };
      };
      ssh.enable = true;
    };

    # Initialize domain join secrets
    sops.secrets."vm-join/user" = { };
    sops.secrets."vm-join/password" = { };
    sops.secrets."vm-join/ou" = { };

    # Autologin to root for access from hypervisor
    services.getty.autologinUser = "root";

    # Local user
    sops.secrets."passwords/local-hashed".neededForUsers = true;
    users.mutableUsers = false;
    users.users.local = {
      isNormalUser = true;
      group = "local";
      hashedPasswordFile = config.sops.secrets."passwords/local-hashed".path;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKxoQSxfYqf9ITN8Fhckk8WbY4dwtBAXOhC9jxihJvq Admin"
      ];
    };
    users.groups.local = { };
    home-manager.users.local =
      { ... }:
      {
        home.stateVersion = "24.11";
        modules.profiles.base.enable = true;
      };

    # System packages
    environment.systemPackages = with pkgs; [
      # TODO: Make module for utilities/scripts
      (writeShellScriptBin "system-update" "nixos-rebuild switch --flake git+https://git.bulthuis.dev/Jan/nixos-config")
    ];

    # Enable qemu guest agent
    services.qemuGuest.enable = true;

    # Machine platform
    nixpkgs.hostPlatform = "x86_64-linux";

    # Set hostid (required for ZFS)
    networking.hostId = "deadbeef";

    # Hardware configuration
    hardware.enableRedistributableFirmware = true;
    boot.initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"
      "9p"
      "9pnet_virtio"
      "sd_mod"
      "sr_mod"
    ];
    boot.kernelModules = [
      "kvm-intel"
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
      "virtio_gpu"
    ];
  };
}
