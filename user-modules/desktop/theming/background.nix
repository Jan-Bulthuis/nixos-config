{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.desktop.theming.background;
in
{
  options.desktop.theming.background = {
    path = mkOption {
      type = types.str;
      default = "minimal/a_flower_on_a_dark_background.png";
      description = "Path to the background image.";
    };
    themed = mkEnableOption "themed background";
    invert = mkEnableOption "invert background";
    src = mkOption {
      default = pkgs.fetchFromGitHub {
        owner = "dharmx";
        repo = "walls";
        rev = "6bf4d733ebf2b484a37c17d742eb47e5139e6a14";
        sha256 = "sha256-M96jJy3L0a+VkJ+DcbtrRAquwDWaIG9hAUxenr/TcQU=";
      };
    };
  };

  config =
    with pkgs;
    let
      theme = writeTextFile {
        name = "gowall-theme";
        text = builtins.toJSON {
          name = "NixOS";
          colors =
            let
              colors = config.desktop.theming.schemeColors;
            in
            [
              "#${colors.base00}"
              "#${colors.base01}"
              "#${colors.base02}"
              "#${colors.base03}"
              "#${colors.base04}"
              "#${colors.base05}"
              "#${colors.base06}"
              "#${colors.base07}"
              "#${colors.base08}"
              "#${colors.base09}"
              "#${colors.base0A}"
              "#${colors.base0B}"
              "#${colors.base0C}"
              "#${colors.base0D}"
              "#${colors.base0E}"
              "#${colors.base0F}"
            ];
        };
        executable = true;
      };

      background-themed = stdenv.mkDerivation {
        name = "background-themed-1.0.0";
        src = cfg.src;

        buildInputs = [
          gowall
          imagemagick
          (writeShellScriptBin "xdg-open" "")
        ];

        buildPhase =
          if cfg.themed then
            if cfg.invert then
              ''
                cp ${theme} ./theme.json

                export HOME=$PWD
                convert ./${cfg.path} -channel RGB -negate ./${cfg.path}

                gowall convert ./${cfg.path} -o themed -t ./theme.json
                mv Pictures/gowall/themed.* ./
                mogrify -format png themed.*
              ''
            else
              ''
                cp ${theme} ./theme.json

                export HOME=$PWD

                gowall convert ./${cfg.path} -o themed -t ./theme.json
                mv Pictures/gowall/themed.* ./
                mogrify -format png themed.*
              ''
          else
            ''
              cp ${cfg.path} ./themed

              mogrify -format png themed
            '';

        installPhase = ''
          install -Dm644 -t $out themed.png
        '';
      };
    in
    {
      programs.wpaperd = {
        enable = true;
        settings.default = {
          path = "${background-themed}/";
          mode = "center";
        };
      };
    };
}
