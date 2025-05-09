{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.retroarch;
in
{
  options.modules.retroarch = {
    enable = mkEnableOption "RetroArch";
  };

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [
      "libretro-fbalpha2012"
      "libretro-fbneo"
      "libretro-fmsx"
      "libretro-genesis-plus-gx"
      "libretro-mame2000"
      "libretro-mame2003"
      "libretro-mame2003-plus"
      "libretro-mame2010"
      "libretro-mame2015"
      "libretro-opera"
      "libretro-picodrive"
      "libretro-snes9x"
      "libretro-snes9x2002"
      "libretro-snes9x2005"
      "libretro-snes9x2005-plus"
      "libretro-snes9x2010"
    ];

    home.packages = with pkgs; [
      # retroarch-full
      retroarch-free
    ];
  };
}
