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
    ./bar/waybar.nix
    ./lock-screen/waylock.nix
    ./window-manager/river.nix
  ];

  options.modules.desktop = {
    wayland = mkEnableOption "wayland";
    # TODO: Find a nicer way to do this as this is also executed on startup
    reloadScript = mkOption {
      type = types.lines;
      default = "";
      description = "Shell script to execute after reload/rebuild.";
    };
    decorations = mkOption {
      type = types.nullOr (
        types.enum [
          "csd"
          "ssd"
        ]
      );
      default = null;
      description = "Window decorations to use.";
    };
  };

  config = mkIf config.desktop.enable (
    lib.recursiveUpdate
      {
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

        # home.file.".initrc" = {
        #   enable = true;
        #   executable = true;
        #   text =
        #     ''
        #       #!${pkgs.bash}/bin/bash

        #     ''
        #     + cfg.initScript;
        # };
      }
      (
        # TODO: Move to dedicated module within desktop or maybe theming?
        # if cfg.decorations == null then
        #   { }
        # else
        #   {
        #     csd = { };
        #     ssd = { };
        #   }
        #   ."${cfg.decorations}"
        { }
      )
  );
}
