{ lib, ... }:

{
  imports = [
    # Import environment
    ../default.nix
  ];

  config = {
    # State version
    system.stateVersion = "24.05";

    # Machine hostname
    networking.hostName = "20212060";

    # Enabled modules
    modules = {
      base.enable = true;
      bluetooth.enable = true;
      power-saving.enable = false;
      networkmanager.enable = true;
      grdp.enable = true;
      printing.enable = true;
    };

    # Hardware configuration
    hardware.enableRedistributableFirmware = true;
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];
    hardware.cpu.intel.updateMicrocode = true;

    # Filesystems
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/3b91eaeb-ea95-4bea-8dc1-f55af7502d23";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/46BF-DE2C";
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
        size = 16 * 1024;
      }
    ];
  };
}
