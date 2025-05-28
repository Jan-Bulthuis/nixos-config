{ lib, config, ... }:

with lib;
let
  cfg = config.modules.power-saving;
in
{
  options.modules.power-saving = {
    enable = mkEnableOption "power saving";
  };
  config = mkIf cfg.enable {
    # Setup power management
    powerManagement.enable = true;
    services.thermald.enable = true;
    services.power-profiles-daemon.enable = true;

    # Enable wifi power saving
    networking.networkmanager.wifi.powersave = true;
  };
}
