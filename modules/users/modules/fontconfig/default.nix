{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.fontconfig;
in {
  options.modules.fontconfig = {
    enable = mkEnableOption "fontconfig";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;

      defaultFonts = {
        serif = [
          config.theming.fonts.serif.name
        ];
        sansSerif = [
          config.theming.fonts.sansSerif.name
        ];
        monospace = [
          config.theming.fonts.monospace.name
        ];
        emoji = [
          config.theming.fonts.emoji.name
        ];
      };
    };
  };
}