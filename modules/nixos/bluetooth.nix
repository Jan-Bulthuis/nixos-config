{ lib, config, ... }:

with lib;
let
  cfg = config.modules.bluetooth;
in
{
  options.modules.bluetooth = {
    enable = mkEnableOption "bluetooth";
  };
  config = mkIf cfg.enable {
    # Enable bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
