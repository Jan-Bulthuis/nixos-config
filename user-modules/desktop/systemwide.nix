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
      desktopManager = {
        xterm.enable = true;
        xfce = {
          enable = true;
        };
      };
    };
  };
}
