{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.bluetooth;
in
{
  options.modules.bluetooth = {
    enable = mkEnableOption "bluetooth";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ bluez ];

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
  };
}
