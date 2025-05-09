{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.waylock;
in
{
  options.modules.waylock = {
    enable = mkEnableOption "waylock";
  };

  config = mkIf cfg.enable {
    home.packages = (with pkgs; [ waylock ]);
  };
}
