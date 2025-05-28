{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.fonts;
in
{
  options.modules.fonts = {
    enable = mkEnableOption "fonts";
  };
  config = mkIf cfg.enable {
    console.packages = [
      pkgs.dina-psfu
    ];
    console.font = "dina";
    console.earlySetup = true;

    # TODO: Disable default fonts, fonts should be managed per user
    # fonts.enableDefaultPackages = false;
    # fonts.fontconfig = {
    #   enable = true;
    #   defaultFonts = {
    #     serif = mkDefault [ ];
    #     sansSerif = mkDefault [ ];
    #     monospace = mkDefault [ ];
    #     emoji = mkDefault [ ];
    #   };
    # };
  };
}
