{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.spotify;
in
{
  options.modules.spotify.enable = mkEnableOption "spotify";

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [
      "spotify"
    ];

    home.packages = with pkgs; [
      spotify
    ];
  };
}
