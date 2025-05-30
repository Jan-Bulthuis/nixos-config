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
      ssh.enable = true;
    };

    # Local user
    services.getty.autologinUser = "local";
    security.sudo.extraRules = [
      {
        users = [ "local" ];
        options = [ "NOPASSWD" ];
      }
    ];
    users.mutableUsers = false;
    users.users.local = {
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keyFiles = [
        config.sops.secrets."ssh-keys/admin-pub".path
      ];
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
