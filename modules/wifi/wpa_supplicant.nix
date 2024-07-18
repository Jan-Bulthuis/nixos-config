{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.wpa_supplicant;
in {
  options.modules.wpa_supplicant = {
    enable = mkEnableOption "wpa_supplicant";
  };

  config = mkIf cfg.enable {
    networking.wireless = {
      enable = true;
      userControlled.enable = true;
      allowAuxiliaryImperativeNetworks = true;
    };
  };
}