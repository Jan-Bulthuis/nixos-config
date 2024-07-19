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

  config = {
    home.packages = mkIf cfg.enable (with pkgs; [ waylock ]);
  };
}
