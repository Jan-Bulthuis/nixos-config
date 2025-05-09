{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.clean-tmp;
in
{
  options.modules.clean-tmp = {
    enable = mkEnableOption "clean-tmp";
  };

  config = mkIf cfg.enable { boot.tmp.cleanOnBoot = true; };
}
