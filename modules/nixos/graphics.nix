{ lib, config, ... }:

with lib;
let
  cfg = config.modules.graphics;
in
{
  options.modules.graphics = {
    enable = mkEnableOption "graphics";
    # TODO: Add toggle for hybrid graphics
  };
  config = mkIf cfg.enable {
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    # TODO: Add nvidia settings back in
    # TODO: Move to nvidia module
    hardware.nvidia = {
      open = true;
    };
  };
}
