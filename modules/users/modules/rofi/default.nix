{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.rofi;
  theme = config.theming;
  colors = theme.colors;
in
{
  options.modules.rofi.enable = mkEnableOption "rofi";

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "${theme.fonts.monospace.name} ${toString theme.fonts.monospace.recommendedSize}";
      theme =
        let
          inherit (config.lib.formats.rasi) mkLiteral;
        in
        {
          "*" = {
            background-color = mkLiteral "rgba(0, 0, 0, 0%)";
            border-color = mkLiteral "#${colors.fg}";
            text-color = mkLiteral "#${colors.fg}";
          };
          mainbox = {
            background-color = mkLiteral "#${colors.bg}";
            border = mkLiteral "${toString theme.layout.borderSize}px";
          };
          element-text = {
            highlight = mkLiteral "#${colors.accent}";
          };
          inputbar = {
            children = mkLiteral "[textbox-search, entry]";
          };
          listview = {
            padding = mkLiteral "2px 0px";
          };
          textbox-search = {
            expand = false;
            content = "> ";
          };
          "inputbar, message" = {
            padding = mkLiteral "2px";
          };
          element = {
            padding = mkLiteral "0px 2px";
          };
          "element selected" = {
            background-color = mkLiteral "#${colors.unfocused}";
          };
        };
    };
  };
}
