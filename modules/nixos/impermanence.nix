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
        Script to run on boot that resets the root partition.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.postResumeCommands = mkAfter cfg.resetScript;

    environment.persistence."/persist/system" = {
      enable = true;
      hideMounts = true;
      directories = cfg.directories;
      files = cfg.files;
    };
  };
}
