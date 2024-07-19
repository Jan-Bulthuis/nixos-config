{config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.qutebrowser;
  theme = config.theming;
in {
  options.modules.qutebrowser.enable = mkEnableOption "qutebrowser";

  config = mkIf cfg.enable {
    programs.qutebrowser = {
      enable = true;

      extraConfig = ''
        config.set("colors.webpage.darkmode.enabled", False)
        config.set("colors.webpage.preferred_color_scheme", "${if theme.darkMode then "dark" else "light"}")
        config.set("fonts.default_family", "${theme.fonts.monospace.name}")
        config.set("fonts.default_size", "${toString theme.fonts.monospace.recommendedSize}pt")
      '';
    };
  };
}