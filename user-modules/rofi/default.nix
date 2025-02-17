{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.rofi;
  theme = config.desktop.theming;
  colors = theme.colors;
in
{
  options.modules.rofi.enable = mkEnableOption "rofi";

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      terminal = config.default.terminal;
      package = pkgs.rofi-wayland;
      font = "${theme.fonts.interface.name} ${toString (theme.fonts.interface.recommendedSize)}";
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
            highlight = mkLiteral "#${colors.fg-search}";
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
            padding = mkLiteral "1px 2px 3px 2px";
          };
          "element selected" = {
            background-color = mkLiteral "#${colors.border-unfocused}";
          };
        };
    };
  };
}
