{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.whatsapp;
in
{
  options.modules.whatsapp = {
    enable = mkEnableOption "whatsapp";
  };

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [ "whatsapp-for-linux" ];

    home.packages = with pkgs; [ whatsapp-for-linux ];
  };
}
