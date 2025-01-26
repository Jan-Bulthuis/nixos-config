{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.pegasus;
in
{
  options.modules.pegasus = {
    enable = mkEnableOption "Pegasus Frontend";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      pegasus-frontend
    ];
  };
}
