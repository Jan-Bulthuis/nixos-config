{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.profiles.desktop;
in
{
  options.modules.profiles.desktop = {
    enable = mkEnableOption "desktop profile";
  };

  config = mkIf cfg.enable {
    modules = {
      profiles.base.enable = mkDefault true;
      fonts.enable = mkDefault true;
      graphics.enable = mkDefault true;
      gnome.enable = mkDefault true; # TODO: Rename to display manager?
      networkmanager.enable = mkDefault true;
      printing.enable = mkDefault true;
      sound.enable = mkDefault true;
    };
  };
}
