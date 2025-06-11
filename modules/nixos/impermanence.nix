{ lib, config, ... }:

with lib;
let
  cfg = config.modules.impermanence;
in
{
  options.modules.impermanence = {
    enable = mkEnableOption "Impermanence";
    directories = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Directories that should be stored in persistent storage.
      '';
    };
    files = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Files that should be stored in persistent storage.
      '';
    };
    resetScript = mkOption {
      type = types.lines;
      description = ''
        Script to run in order to reset the system to a clean state.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Filesystem setup
    fileSystems."/persist".neededForBoot = true;
    # boot.initrd.postResumeCommands = mkAfter cfg.resetScript;
    # TODO: Reduce dependency on the root filesystem being ZFS?
    boot.initrd.systemd.services.impermanence-rollback = {
      description = "Rollback filesystem to clean state.";
      wantedBy = [ "initrd.target" ];
      after = [ "zfs-import.target" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = cfg.resetScript;
    };

    # For home-manager persistence
    programs.fuse.userAllowOther = true;

    # For testing purposes with VM
    virtualisation.vmVariantWithDisko.virtualisation.fileSystems."/persist".neededForBoot = true;

    environment.persistence."/persist/system" = {
      enable = true;
      hideMounts = true;
      directories = cfg.directories;
      files = cfg.files;
    };
  };
}
