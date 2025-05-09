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
    # TODO: Move to audioling
    home.packages = with pkgs; [ feishin ];

    # TODO: Remove exception once no longer required by feishin
    nixpkgs.config.permittedInsecurePackages = [
      "electron-33.4.11"
      "freeimage-3.18.0-unstable-2024-04-18"
    ];
  };
}
