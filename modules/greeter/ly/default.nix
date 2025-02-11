{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.ly;
in
{
  options.modules.ly = {
    enable = mkEnableOption "ly";
  };

  config = mkIf cfg.enable {
    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = "matrix";
        box_title = " Hewwo! >_< :3 ";
        clear_password = true;
        load = true;
        save = true;
      };
    };
  };
}
