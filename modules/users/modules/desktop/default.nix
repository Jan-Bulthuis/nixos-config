{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  imports = [
    # Import desktop environment modules
    ./lock-screen/waylock.nix
    ./window-manager/river.nix
  ];

  options.modules.desktop = {
    initScript = mkOption {
      type = types.lines;
      default = "${pkgs.bash}/bin/bash";
      description = "Bash script to execute after logging in.";
    };
  };

  config = {
    home.file.".initrc" = {
      enable = true;
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash

      '' + cfg.initScript;
    };
  };
}
