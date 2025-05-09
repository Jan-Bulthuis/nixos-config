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
    image = {
      url = mkOption {
        type = types.str;
        default = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/digital/a_drawing_of_a_spider_on_a_white_surface.png";
        description = "URL to the background image.";
      };
      hash = mkOption {
        type = types.str;
        default = "sha256-eCEjM7R9yeHNhZZtvHjrgkfwT25JA7FeMoVwnQ887CQ=";
        description = "SHA256 hash of the background image.";
      };
    };
    themed = mkEnableOption "themed background";
    inverted = mkEnableOption "invert background";
  };

  config =
    with pkgs;
    let
      src = pkgs.fetchurl {
        url = cfg.image.url;
        hash = cfg.image.hash;
      };

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

      fileExtension =
        name:
        let
          parts = splitString "." name;
        in
        if length parts > 1 then lists.last parts else "";

      fileName =
        name:
        let
          parts = splitString "/" name;
        in
        if length parts > 1 then lists.last parts else name;

      image = fileName cfg.image.url;

      background-themed = stdenv.mkDerivation {
        name = "background-themed-1.0.0";
        src = src;

        buildInputs = [
          gowall
          imagemagick
          (writeShellScriptBin "xdg-open" "")
          tree
        ];

        unpackPhase = ''
          cp ${src} ./${image}
          chmod u+w ./${image}
        '';

        buildPhase = ''
          ${optionalString cfg.inverted ''
            convert ./${image} -channel RGB -negate ./${image}
          ''}
          ${optionalString cfg.themed ''
            cp ${theme} ./theme.json

            export HOME=$PWD

            gowall convert ./${image} --output themed -t ./theme.json
            tree
            mv ./themed/*.* ./
          ''}
          mv ./${image} themed.${fileExtension image}
          ${optionalString (fileExtension image != "png") ''
            mogrify -format png themed.*
          ''}
        '';

        installPhase = ''
          install -Dm644 -t $out themed.png
        '';
      };
    in
    {
      services.wpaperd = {
        enable = true;
        settings.default = {
          path = "${background-themed}/";
          mode = "center";
        };
      };
    };
}
