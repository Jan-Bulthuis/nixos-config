{ lib, ... }:

{
  imports = [
    # Import environment
    ../default.nix
  ];

  config = {
    # State version
    system.stateVersion = "24.11";

    # Machine hostname
    networking.hostName = lib.mkDefault "vm-base";

    # Enabled modules
    modules = {
      base.enable = true;
      ssh.enable = true;
    };

    # Enable qemu guest agent
    services.qemuGuest.enable = true;

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

    # Filesystems
    fileSystems."/" = {
      device = "/dev/disk/by-partlabel/root";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/EFI";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    # Swapfile
    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 6 * 1024;
      }
    ];
  };
}
