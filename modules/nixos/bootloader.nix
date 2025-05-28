{ lib, config, ... }:

with lib;
let
  cfg = config.modules.bootloader;
in
{
  options.modules.bootloader = {
    enable = mkEnableOption "bootloader";
  };
  config = mkIf cfg.enable {
    # Bootloader
    boot.loader = {
      timeout = 0;
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
    };
  };
}
