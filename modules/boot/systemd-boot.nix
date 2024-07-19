{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.systemd-boot;
in
{
  options.modules.systemd-boot = {
    enable = mkEnableOption "systemd-boot";
  };

  config = mkIf cfg.enable {
    boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
    };
  };
}
