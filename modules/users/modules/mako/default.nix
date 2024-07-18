{config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.mako;
  theme = config.theming;
  colors = theme.colors;
in {
  options.modules.mako.enable = mkEnableOption "mako";

  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      anchor = "top-right";
      defaultTimeout = 5000;
      backgroundColor = "#${colors.bg}ff";
      textColor = "#${colors.fg}ff";
      borderColor = "#${colors.fg}ff";
      progressColor = "#${colors.accent}ff";
      borderRadius = 0;
      borderSize = theme.layout.borderSize;
      font = "${theme.fonts.monospace.name} ${toString theme.fonts.monospace.recommendedSize}";
    };
  };
}