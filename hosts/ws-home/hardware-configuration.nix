{ ... }:

# TODO: Replace with output of `nixos-generate-config --show-hardware-config`
{
  # Hardware configuration
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.zfs.forceImportRoot = false;
  hardware.cpu.intel.updateMicrocode = true;
}
