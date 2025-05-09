{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.desktop.theming.themes.papercolor;
  mode = if cfg.darkMode then "dark" else "light";
in
{
  options = {
    desktop.theming.themes.papercolor = {
      enable = mkEnableOption "papercolor";
      darkMode = mkEnableOption "dark mode";
    };
  };

  config.desktop.theming = mkIf cfg.enable {
    darkMode = cfg.darkMode;
    colorScheme = "${pkgs.base16-schemes}/share/themes/papercolor-${mode}.yaml";
  };
}
