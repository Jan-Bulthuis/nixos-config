{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.networkmanager;
in
{
  options.modules.networkmanager = {
    enable = mkEnableOption "networkmanager";
  };

  config = mkIf cfg.enable {
    machine.sudo-groups = [ "networkmanager" ];
    networking = {
      networkmanager = {
        enable = true;
        wifi.powersave = true;
      };
    };
  };
}
