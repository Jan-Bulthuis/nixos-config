{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.theming.themes.catppuccin;
in
{
  options = {
    theming.themes.catppuccin = {
      enable = mkEnableOption "catppuccin";
      flavor = mkOption {
        type = types.enum [
          "latte"
          "frappe"
          "macchiato"
          "mocha"
        ];
        default = "mocha";
        description = "The flavor of catppuccin theme.";
      };
    };
  };

  config.theming = mkIf cfg.enable {
    darkMode = (cfg.flavor != "latte");
    colorScheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${cfg.flavor}.yaml";
  };
}
