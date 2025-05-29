{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.bitwarden;
in
{
  options.modules.bitwarden = {
    enable = mkEnableOption "Bitwarden";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
    ];
  };
}
