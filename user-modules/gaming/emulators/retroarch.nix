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
    home.packages = with pkgs; [
      retroarch-free
    ];
  };
}
