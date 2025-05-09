{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.desktop.theming.themes.gruvbox;
  mode = if cfg.darkMode then "dark" else "light";
in
{
  options = {
    desktop.theming.themes.gruvbox = {
      enable = mkEnableOption "gruvbox-hard";
      darkMode = mkEnableOption "dark mode";
      contrast = mkOption {
        type = types.enum [
          "hard"
          "medium"
          "soft"
        ];
        default = "hard";
        description = "The contrast level of the theme.";
      };
    };
  };

  config.desktop.theming = mkIf cfg.enable {
    darkMode = cfg.darkMode;
    colorScheme = "${pkgs.base16-schemes}/share/themes/gruvbox-${mode}-${cfg.contrast}.yaml";
  };
}
