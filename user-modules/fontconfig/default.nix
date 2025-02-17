{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.fontconfig;

  aliasConfig = font: ''
    <alias>
      <family>${font.name}</family>

      <prefer>
        <family>${font.name}</family>
    ${concatStrings (map (font: "    <family>${font}</family>\n") font.fallbackFonts)}
      </prefer>
    </alias>
  '';

  configContent = concatStrings (
    map (
      font: aliasConfig config.desktop.theming.fonts.pkgs.${font}
    ) config.desktop.theming.fonts.installed
  );
in
{
  options.modules.fontconfig = {
    enable = mkEnableOption "fontconfig";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;

      defaultFonts = {
        serif = [ config.desktop.theming.fonts.serif.name ];
        sansSerif = [ config.desktop.theming.fonts.sansSerif.name ];
        monospace = [ config.desktop.theming.fonts.monospace.name ];
        emoji = [ config.desktop.theming.fonts.emoji.name ];
      };
    };

    home.file.".config/fontconfig/conf.d/20-family-fallbacks.conf" = {
      enable = true;

      # text = ''
      #   <?xml version="1.0"?>
      #   <fontconfig>

      #   ${configContent}
      #   </fontconfig>
      # '';
      text = ''
        <?xml version='1.0'?>
        <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
        <fontconfig>

        ${configContent}
        </fontconfig>
      '';
    };
  };
}
