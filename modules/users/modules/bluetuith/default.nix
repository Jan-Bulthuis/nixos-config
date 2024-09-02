{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.bluetuith;
in
{
  options.modules.bluetuith = {
    enable = mkEnableOption "bluetuith";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ bluetuith ];

    # Add nix tree
    xdg.desktopEntries.bluetuith = {
      exec = "${pkgs.bluetuith}/bin/bluetuith";
      name = "Bluetuith";
      terminal = true;
      type = "Application";
    };
  };
}
