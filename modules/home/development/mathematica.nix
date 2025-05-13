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
    # source = ./Wolfram_14.2.1_LIN_Bndl.sh;
  };
in
{
  options.modules.mathematica = {
    enable = mkEnableOption "mathematica";
  };

  config = mkIf cfg.enable {
    home.packages = [
      my-mathematica
    ];
  };
}
