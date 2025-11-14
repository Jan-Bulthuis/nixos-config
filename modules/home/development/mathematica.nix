{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.mathematica;

  my-mathematica = pkgs.mathematica.overrideAttrs (old: {
    force-rebuild = "1";
    # TODO: Just use a generic name for the installer?
    # source = ./Wolfram_14.2.1_LIN_Bndl.sh;
  });
in
{
  options.modules.mathematica = {
    enable = mkEnableOption "mathematica";
  };

  config = mkIf cfg.enable {
    home.packages = [
      # pkgs.mathematica-cuda
      my-mathematica
    ];
  };
}
