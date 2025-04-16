{ config, lib, ... }:

with lib;
{
  options.modules.grdp = {
    enable = mkEnableOption "grdp";
  };

  config = mkIf config.modules.grdp.enable {
    services.gnome.gnome-remote-desktop.enable = true;
    systemd.services."gnome-remote-desktop".wantedBy = [ "graphical.target" ];
    networking.firewall = {
      allowedTCPPorts = [ 3389 ];
      allowedUDPPorts = [ 3389 ];
    };
    # programs.dconf.profiles.user.databases = [
    #   {
    #     settings = with lib.gvariant; {
    #       "org/gnome/desktop/remote-desktop/rdp" = {
    #         enable = true;
    #         view-only = false;
    #       };
    #     };
    #   }
    # ];
  };
}
