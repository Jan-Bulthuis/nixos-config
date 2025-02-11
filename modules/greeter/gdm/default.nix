{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.gdm;
in
{
  options.modules.gdm = {
    enable = mkEnableOption "gdm";
  };

  config = mkIf cfg.enable {
    # services.xserver = {
    #   enable = true;
    #   displayManager.gdm.enable = true;
    #   displayManager.gdm.wayland = true;
    #   libinput.enable = true;
    # };
    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = "matrix";
        box_title = "Hewwo! >_< :3";
        clear_password = true;
        load = true;
        save = true;
      };
    };
  };
}
