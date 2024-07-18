{config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.feishin;
in {
  options.modules.feishin.enable = mkEnableOption "feishin";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      feishin
    ];
  };
}