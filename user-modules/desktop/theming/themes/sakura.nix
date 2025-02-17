{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.desktop.theming.themes.sakura;
in
{
  options = {
    desktop.theming.themes.sakura = {
      enable = mkEnableOption "sakura";
    };
  };

  config.desktop.theming = mkIf cfg.enable {
    darkMode = false;
    colorScheme = "${pkgs.base16-schemes}/share/themes/sakura.yaml";
  };
}
