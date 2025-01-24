{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.feishin;
in
{
  options.modules.feishin.enable = mkEnableOption "feishin";

  config = mkIf cfg.enable {
    # TODO: Remove insecure package exception
    nixpkgs.config.permittedInsecurePackages = [ "electron-31.7.7" ];

    # TODO: Move to audioling
    home.packages = with pkgs; [ feishin ];
  };
}
