{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.desktop;
in
{
  imports = [
    # Import desktop environment modules
    ./background/glpaper/default.nix
    ./bar/waybar.nix
    ./lock-screen/waylock.nix
    ./window-manager/river.nix
  ];

  options.modules.desktop = {
    wayland = mkEnableOption "wayland";
    initScript = mkOption {
      type = types.lines;
      default = "${pkgs.bash}/bin/bash";
      description = "Bash script to execute after logging in.";
    };
  };

  config = {
    # Ensure desktop related systemd services (xdg) have access to session variables.
    systemd.user.sessionVariables = config.home.sessionVariables;

    home.packages = optionals cfg.wayland (
      with pkgs;
      [
        pkgs.wl-clipboard
        pkgs.wtype
        pkgs.grim
        pkgs.slurp
      ]
    );

    home.file.".initrc" = {
      enable = true;
      executable = true;
      text =
        ''
          #!${pkgs.bash}/bin/bash

        ''
        + cfg.initScript;
    };
  };
}
