{
  lib,
  pkgs,
  config,
  ...
}:

{
  # State version
  system.stateVersion = "24.11";

  # Machine hostname
  networking.hostName = "vm-vpn";

  # Enabled modules
  modules = {
    profiles.vm.enable = true;
  };

  # Setup wstunnel server
  services.wstunnel = {
    enable = true;
    servers.wg-tunnel = {
      enableHTTPS = false;
      listen = {
        host = "0.0.0.0";
        port = 8080;
      };
      restrictTo = [
        {
          host = "10.10.40.100";
          port = 51820;
        }
      ];
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
  };
}
