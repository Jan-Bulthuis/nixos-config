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

    # TODO: Remove once nixpkgs updates
    nixpkgs.config.packageOverrides = pkgs: {
      python3 = pkgs.python3.override {
        packageOverrides = self: super: {
          pykeepass = super.pykeepass.overrideAttrs (attrs: {
            version = "4.1.0.post1";
            src = pkgs.fetchFromGitHub {
              owner = "libkeepass";
              repo = "pykeepass";
              rev = "refs/tags/v4.1.0.post1";
              hash = "sha256-64is/XoRF/kojqd4jQIAQi1od8TRhiv9uR+WNIGvP2A=";
            };
          });
        };
      };
    };

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
