{
  pkgs,
  ...
}:

{
  home.stateVersion = "25.11";

  modules.profiles.jan.enable = true;

  # home.packages = with pkgs; [
  #   opencloud-desktop
  #   code-nautilus
  #   nautilus-open-in-blackbox
  # ];

  xdg.desktopEntries = {
    canvas = {
      name = "Canvas";
      type = "Application";
      exec = "${pkgs.chromium}/bin/chromium --app=\"https://canvas.tue.nl\" --user-data-dir=/home/jan/.local/state/Canvas";
      settings.StartupWMClass = "chrome-canvas.tue.nl__-Default";
    };
    overleaf = {
      name = "Overleaf";
      type = "Application";
      exec = "${pkgs.chromium}/bin/chromium --app=\"https://www.overleaf.com\" --user-data-dir=/home/jan/.local/state/Overleaf";
      settings.StartupWMClass = "chrome-www.overleaf.com__-Default";
    };
  };
}
