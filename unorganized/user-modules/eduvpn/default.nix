{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.eduvpn;
in
{
  options.modules.eduvpn = {
    enable = mkEnableOption "EduVPN";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [
      eduvpn-client
    ];
  };
}
