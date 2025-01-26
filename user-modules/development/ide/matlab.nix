{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.matlab;
in
{
  options.modules.matlab = {
    enable = mkEnableOption "matlab";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      matlab
    ];

    home.sessionVariables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
