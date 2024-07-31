{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.obsidian;
in
{
  options.modules.obsidian = {
    enable = mkEnableOption "obsidian";
  };

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [ "obsidian" ];

    home.packages = with pkgs; [ obsidian ];
  };
}
