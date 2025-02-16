{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.i3;
in
{
  options.modules.i3.enable = lib.mkEnableOption "i3";

  config = lib.mkIf cfg.enable {
    # Set desktop type to x11
    # modules.desktop.x11 = true;
    modules.rofi.enable = true;

    modules.desktop.initScript = ''
      i3
    '';

    xsession.windowManager.i3 = {
      enable = true;
    };

    # Systemwide configuration
    systemwide = {
      services.xserver = {
        layout = "us";
        xkbVariant = "";
        enable = true;
        windowManager.i3.enable = true;
        desktopManager = {
          xterm.enable = true;
          xfce = {
            enable = true;
            # noDesktop = false;
            # enableXfwm = false;
          };
        };
      };
    };
  };
}
