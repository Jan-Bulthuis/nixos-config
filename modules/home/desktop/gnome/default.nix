{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.desktop.gnome;
in
{
  options.modules.desktop.gnome = {
    enable = mkEnableOption "gnome";
  };

  config = mkIf cfg.enable {
    # TODO: Enable extensions with dconf

    home.packages =
      with pkgs;
      [
        gnome-control-center
        gnome-tweaks
        blackbox-terminal
      ]
      ++ (with pkgs.gnomeExtensions; [
        gsconnect
        disable-workspace-animation
      ]);
  };
}
