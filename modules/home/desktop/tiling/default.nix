{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.desktop.tiling;
in
{
  options.modules.desktop.tiling = {
    enable = mkEnableOption "tiling desktop";
  };

  config = mkIf cfg.enable {
    
  };
}
