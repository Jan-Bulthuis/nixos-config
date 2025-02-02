{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  enabled = any (user: user.modules.i3.enable) (attrValues config.home-manager.users);
in
{
  config = mkIf enabled {
    services.xserver = {
      layout = "us";
      xkbVariant = "";
      enable = true;
      windowManager.i3.enable = true;
      desktopManager = {
        xterm.enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
  };
}
