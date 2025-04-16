{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    # Import environment
    ./vm-base.nix
  ];

  config = {
    # Machine hostname
    networking.hostName = "vm-audio";

    # Enabled modules
    modules = {
    };

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

    # User for audio mixing
    users.users.mixer = {
      isNormalUser = true;
      group = "mixer";
      extraGroups = [ "systemd-journal" ];
    };
    users.groups.mixer = { };

    # Extra packages
    environment.systemPackages = with pkgs; [
      wprs
      xwayland
    ];

    # wprsd service
    systemd.user.services.wprsd = {
      description = "wprsd Service";
      wantedBy = [ "default.target" ];
      after = [ "network.target" ];
      unitConfig = {
        ConditionUser = "mixer";
      };
      serviceConfig = {
        ExecStart = "${pkgs.wprs}/bin/wprsd";
        Environment = "\"RUST_BACKTRACE=full\"";
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
