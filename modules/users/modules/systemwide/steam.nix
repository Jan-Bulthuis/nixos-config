{ lib, config, pkgs, ... }:

with lib;
let
  enabled = any (user: user.modules.steam.enable) (attrValues config.home-manager.users);
in {
  config = mkIf enabled {
    programs.steam.enable = true;
  };
}