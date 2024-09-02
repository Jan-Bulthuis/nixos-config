{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.theming.themes.oxocarbon;
  mode = if cfg.darkMode then "dark" else "light";
in
{
  options = {
    theming.themes.oxocarbon = {
      enable = mkEnableOption "oxocarbon";
      darkMode = mkEnableOption "dark mode";
    };
  };

  config.theming = mkIf cfg.enable {
    darkMode = cfg.darkMode;
    colorScheme = "${pkgs.base16-schemes}/share/themes/oxocarbon-${mode}.yaml";
  };
}
