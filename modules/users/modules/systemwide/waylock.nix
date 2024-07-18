{ lib, config, pkgs, ... }:

with lib;
let
  enabled = any (user: user.modules.waylock.enable) (attrValues config.home-manager.users);
in {
  config = mkIf enabled {
    security.pam.services.waylock = {};
  };
}