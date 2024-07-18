{config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.winbox;
in {
  options.modules.winbox = {
    enable = mkEnableOption "winbox";
  };

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [ "winbox" ];

    home.packages = with pkgs; [
      winbox
    ];
  };
}