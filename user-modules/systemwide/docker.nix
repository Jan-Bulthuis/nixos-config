{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  enabled = any (user: user.modules.docker.enable) (attrValues config.home-manager.users);
in
{
  config = mkIf enabled {
    virtualisation.docker.enable = true;
    machine.sudo-groups = [ "docker" ];
  };
}
