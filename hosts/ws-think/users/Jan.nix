{
  pkgs,
  ...
}:

{
  home.stateVersion = "25.11";

  modules.profiles.jan.enable = true;

  # Open Beat Saber OneClick links on the Steam Frame
  modules.beatsaber-oneclick = {
    enable = true;
    host = "steamos@frame.local";
  };

  # Larger text while the desktop is streamed to the Steam Frame
  modules.steam-frame-desktop = {
    enable = true;
    streamingTextScale = 1.2;
  };

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

  # TODO: Slowly remove
  modules.impermanence = {
    directories = [
      ".cache"
      ".config"
      ".cargo"
      ".dbus"
      ".gnupg"
      ".local"
      ".MathWorks"
      ".mozilla"
      ".ssh"
      ".steam"
      ".SteamCloud"
      ".thunderbird"
      ".vscode"
      ".vscode-shared"
      ".var/app"
      ".wine"
      ".Wolfram"
    ];
  };
}
