{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.keyring;
in
{
  options.modules.keyring = {
    enable = mkEnableOption "keyring";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      seahorse
    ];
    services.gnome-keyring.enable = true;
  };
}
