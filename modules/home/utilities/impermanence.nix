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
  };

  config = mkIf cfg.enable {
    home.persistence."/persist/home" = {
      enable = true;
      hideMounts = true;
      directories = cfg.directories;
      files = cfg.files;
    };
  };
}
