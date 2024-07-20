{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.foot;
in
{
  options.modules.foot.enable = mkEnableOption "foot";

  config = mkIf cfg.enable {
    default.terminal = mkDefault "${pkgs.foot}/bin/foot";

    programs.foot = {
      enable = true;
      settings = {
        main =
          let
            font = config.theming.fonts.monospace.name;
            size = toString config.theming.fonts.monospace.recommendedSize;
          in
          {
            font = mkForce "${font}:style=Regular:size=${size}";
            font-bold = "${font}:style=Bold:size=${size}";
            font-italic = "${font}:style=Italic:size=${size}";
            font-bold-italic = "${font}:style=Bold Italic:size=${size}";
          };
      };
    };
  };
}
