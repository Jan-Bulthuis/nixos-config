{config, lib, pkgs, ... }:

let
  cfg = config.modules.zathura;
in {
  options.modules.zathura.enable = lib.mkEnableOption "zathura";

  config = lib.mkIf cfg.enable {
    programs.zathura = {
      enable = true;

      options = {
        guioptions = "none";
      };
    };
  };
}