{
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
      profiles.server.enable = true;
      disko.profile = mkDefault "vm";
    };

    # Autologin to root for access from hypervisor
    services.getty.autologinUser = "root";

    # Enable qemu guest agent
    services.qemuGuest.enable = true;

    # Hardware configuration
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
