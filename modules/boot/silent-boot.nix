{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.silent-boot;
in {
  options.modules.silent-boot = {
    enable = mkEnableOption "silent-boot";
  };

  config = mkIf cfg.enable {
    boot = {
        loader.timeout = 0;
    };

    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.checkJournalingFS = false;

    kernelParams = [
      "quiet"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "video=efifb:nobgrt"
      "bgrt_disable"
    ];
  };
}