{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.fontconfig;
in
{
  options.modules.fontconfig = {
    enable = mkEnableOption "fontconfig";
  };

  config = {
    fonts.fontconfig.enable = cfg.enable;
    fonts.enableDefaultPackages = false;
    fonts.fontconfig.defaultFonts = {
      serif = mkDefault [ ];
      sansSerif = mkDefault [ ];
      monospace = mkDefault [ ];
      emoji = mkDefault [ ];
    };
  };
}
