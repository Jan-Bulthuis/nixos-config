{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.mathematica;
in
{
  options.modules.mathematica = {
    enable = mkEnableOption "mathematica";
  };

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [
      "mathematica"
    ];

    home.packages = with pkgs; [
      mathematica
    ];
  };
}
