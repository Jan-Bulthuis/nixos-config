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
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = true;
      libinput.enable = true;
    };
  };
}
