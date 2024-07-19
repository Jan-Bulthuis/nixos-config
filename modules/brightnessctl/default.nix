{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.brightnessctl;
in
{
  options.modules.brightnessctl = {
    enable = mkEnableOption "brightnessctl";
  };

  config = mkIf cfg.enable { environment.systemPackages = [ pkgs.brightnessctl ]; };
}
