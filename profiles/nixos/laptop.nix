{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.profiles.laptop;
in
{
  options.modules.profiles.laptop = {
    enable = mkEnableOption "laptop profile";
  };

  config = mkIf cfg.enable {
    # Setup modules
    modules = {
      profiles.desktop.enable = mkDefault true;
      bluetooth.enable = mkDefault true;
      power-saving.enable = mkDefault true;
    };

    # Add packages
    environment.systemPackages = with pkgs; [
      brightnessctl
    ];
  };
}
