{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.waylock;
in {
  options.modules.waylock = {
    enable = mkEnableOption "waylock";
    system = mkOption {
      type = types.attrsOf types.anything;
      description = "System wide configuration to apply if module is enabled";
    };
  };

  config = {
    modules.waylock.system = mkForce {
      security.pam.services.waylock = {};
    };

    home.packages = mkIf cfg.enable (with pkgs; [
      waylock
    ]);
  };
}