{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  enabled = any (user: user.modules.keyring.enable) (attrValues config.home-manager.users);
in
{
  config = mkIf enabled {
    services.gnome.gnome-keyring = {
      enable = true;
    };
  };
}
