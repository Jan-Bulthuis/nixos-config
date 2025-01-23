{
  lib,
  config,
  ...
}:

with lib;
let
  enabled = any (user: user.modules.steam.enable) (attrValues config.home-manager.users);
in
{
  config = mkIf enabled {
    modules.unfree.allowedPackages = [
      "steam"
      "steam-original"
      "steam-unwrapped"
    ];

    programs.steam.enable = true;
  };
}
