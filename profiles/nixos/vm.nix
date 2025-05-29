{
  mkModule,
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
      ssh.enable = true;
    };

    # Admin users
    users.users.local = {
      initialPassword = "local";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519  jan@bulthuis.dev"
      ];
    };

    # Enable qemu guest agent
    services.qemuGuest.enable = true;

    # Machine platform
    nixpkgs.hostPlatform = "x86_64-linux";

    # Set hostid for ZFS
    networking.hostId = "deadbeef";

    # Hardware configuration
    hardware.enableRedistributableFirmware = true;
    boot.initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];
    hardware.cpu.intel.updateMicrocode = true;

    # Swapfile
    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 6 * 1024;
      }
    ];
  };
}
