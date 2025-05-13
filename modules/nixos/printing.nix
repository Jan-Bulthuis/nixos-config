{ lib, config, ... }:

with lib;
let
  cfg = config.modules.printing;
in
{
  options.modules.printing = {
    enable = mkEnableOption "printing";
  };
  config = mkIf cfg.enable {
    # Enable CUPS
    services.printing.enable = true;

    # Enable Avahi to auto-detect network printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
