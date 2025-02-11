{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.qutebrowser;
  theme = config.theming;
in
{
  options.modules.qutebrowser = {
    enable = mkEnableOption "qutebrowser";
    default = mkEnableOption "default";
  };

  config = mkIf cfg.enable {
    default.browser = mkIf cfg.default "org.qutebrowser.qutebrowser.desktop";

    programs.qutebrowser = {
      enable = true;

      extraConfig = ''
        config.set("completion.web_history.max_items", 256)
        config.set("colors.webpage.darkmode.enabled", False)
        config.set("colors.webpage.preferred_color_scheme", "${if theme.darkMode then "dark" else "light"}")
        config.set("fonts.default_family", "${theme.fonts.interface.name}")
        config.set("fonts.default_size", "${toString theme.fonts.interface.recommendedSize}pt")
      '';
    };
  };
}
