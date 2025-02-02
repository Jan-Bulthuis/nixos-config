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
    ./window-manager/i3.nix
    ./window-manager/river.nix
  ];

  options.modules.desktop = {
    wayland = mkEnableOption "wayland";
    initScript = mkOption {
      type = types.lines;
      default = "${pkgs.bash}/bin/bash";
      description = "Bash script to execute after logging in.";
    };
    reloadScript = mkOption {
      type = types.lines;
      default = "";
      description = "Shell script to execute after reload/rebuild.";
    };
  };

  config = {
    # Ensure desktop related systemd services (xdg) have access to session variables.
    systemd.user.sessionVariables = config.home.sessionVariables;

    home.packages = optionals cfg.wayland (
      with pkgs;
      [
        wl-clipboard
        wtype
        grim
        slurp
      ]
    );

    home.activation = {
      customReloadScript = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        ''
          #!${pkgs.bash}/bin/bash
        ''
        + cfg.reloadScript
      );
    };

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
