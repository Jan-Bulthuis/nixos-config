{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.modules.grdp = {
    enable = mkEnableOption "grdp";
  };

  config = mkIf config.modules.grdp.enable {
    services.gnome.gnome-remote-desktop.enable = true;
    environment.systemPackages = with pkgs; [
      gnome-remote-desktop
      gnome-control-center
      gnome-session
      gnome-shell
      gnome-settings-daemon
      gdm
    ];
    systemd.services."gnome-remote-desktop".wantedBy = [ "graphical.target" ];
    networking.firewall = {
      allowedTCPPorts = [ 3389 ];
      allowedUDPPorts = [ 3389 ];
    };
    services.xserver.displayManager.gdm.enable = true;
    modules.greetd.enable = mkForce false;

    # security.polkit.extraConfig = ''
    #   polkit.addRule(function(action, subject) {
    #     if (action.id == "org.gnome.controlcenter.remote-session-helper" &&
    #         subject.isInGroup("wheel")) {
    #       return polkit.Result.YES;
    #     }
    #   });'';
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
