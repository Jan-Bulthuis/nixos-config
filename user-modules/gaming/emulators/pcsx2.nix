{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.pcsx2;
in
{
  options.modules.pcsx2 = {
    enable = mkEnableOption "pcsx2";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pcsx2
    ];
  };
}
