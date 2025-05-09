{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.desktop.theming.themes.nord;
  mode = if cfg.darkMode then "" else "-light";
in
{
  options = {
    desktop.theming.themes.nord = {
      enable = mkEnableOption "nord";
      darkMode = mkEnableOption "dark mode";
    };
  };

  config.desktop.theming = mkIf cfg.enable {
    darkMode = cfg.darkMode;
    colorScheme = "${pkgs.base16-schemes}/share/themes/nord${mode}.yaml";
  };
}
