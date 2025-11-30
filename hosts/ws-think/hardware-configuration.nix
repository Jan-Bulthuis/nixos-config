{ ... }:

{
  # Machine platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Set hostid (required for ZFS)
  networking.hostId = "deadbeef";

  modules.disko = {
    enable = true;
    profile = "ws-think";
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
  fileSystems = {
    "/" = {
      device = "tank/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

    "/nix" = {
      device = "tank/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

    "/persist" = {
      device = "tank/persist";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/46BF-DE2C";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };
}
