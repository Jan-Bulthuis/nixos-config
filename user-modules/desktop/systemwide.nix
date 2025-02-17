{
  waylock = {
    security.pam.services.waylock = { };
  };
  river = {
    programs.river.enable = true;
  };
  i3 = {
    services.xserver = {
      layout = "us";
      xkbVariant = "";
      enable = true;
      windowManager.i3.enable = true;
      desktopManager = {
        xterm.enable = true;
        xfce = {
          enable = true;
        };
      };
    };
  };
}
