{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.mathematica;

  my-mathematica = pkgs.mathematica.override {
    # TODO: Just use a generic name for the installer?
    source = ./Wolfram_14.1.0_LIN_Bndl.sh;
  };
in
{
  options.modules.mathematica = {
    enable = mkEnableOption "mathematica";
  };

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [
      "mathematica"
    ];

    home.packages = [
      my-mathematica
    ];
  };
}
