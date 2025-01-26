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
    home.packages = with pkgs; [
      emulationstation-de
    ];

    home.sessionVariables = {
      ESDE_APPDATA_DIR = "$HOME/.config/ES-DE";
    };
  };
}
