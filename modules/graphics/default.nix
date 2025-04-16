{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.fontconfig;
in
{
  options.modules.graphics = {
    enable = mkEnableOption "graphics";
  };
  config = mkIf cfg.enable {
    # TODO: Modularize further, especially modesetting should be its own module.
    # Set up graphics
    hardware.graphics.enable32Bit = true;
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
  };
}
