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
      open = false;
      powerManagement.enable = true;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:1@0:0:0";
      };
    };
  };
}
