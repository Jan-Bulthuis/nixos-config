{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.theming.themes.sakura;
in
{
  options = {
    theming.themes.sakura = {
      enable = mkEnableOption "sakura";
    };
  };

  config.theming = mkIf cfg.enable {
    darkMode = false;
    colorScheme = "${pkgs.base16-schemes}/share/themes/sakura.yaml";
  };
}
