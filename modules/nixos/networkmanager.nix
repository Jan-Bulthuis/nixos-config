{ lib, config, ... }:

with lib;
let
  cfg = config.modules.networkmanager;
in
{
  options.modules.networkmanager = {
    enable = mkEnableOption "networkmanager";
  };
  config = mkIf cfg.enable {
    # TODO: Add sudo users to the networkmanager group?
    networking.networkmanager.enable = true;
  };
}
