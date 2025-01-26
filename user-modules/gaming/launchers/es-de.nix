{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.es-de;
in
{
  options.modules.es-de = {
    enable = mkEnableOption "Emulation Station Desktop Edition";
  };

  config = mkIf cfg.enable {
    # TODO: Remove insecure package
    nixpkgs.config.permittedInsecurePackages = [
      "freeimage-unstable-2021-11-01"
    ];

    home.packages = with pkgs; [
      emulationstation-de
    ];
  };
}
