{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  enabled = any (user: user.modules.river.enable) (attrValues config.home-manager.users);
in
{
  config = mkIf enabled { programs.river.enable = true; };
}
