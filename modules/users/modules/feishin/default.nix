{config, lib, pkgs, ... }:

let
  cfg = config.modules.feishin;
in {
  options.modules.feishin.enable = lib.mkEnableOption "feishin";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      feishin
    ];
  };
}