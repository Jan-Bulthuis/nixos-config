{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.rofi-rbw;
in
{
  options.modules.rofi-rbw.enable = mkEnableOption "rofi-rbw";

  config = mkIf cfg.enable {
    modules.rofi.enable = true;

    home.packages = [ pkgs.rofi-rbw ];

    # TODO: Move to separate module and make configurable
    programs.rbw = {
      enable = true;
      settings = {
        base_url = "https://keys.bulthuis.dev";
        email = "jan@bulthuis.dev";
        pinentry = pkgs.pinentry;
      };
    };
  };
}
