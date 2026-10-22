{
  ...
}:

{
  # State version
  system.stateVersion = "25.05";

  # Machine hostname
  networking.hostName = "ws-home";

  # Enabled modules
  modules = {
    profiles.server.enable = true;
    disko.profile = "ws-home";
  };

  # Matter controller
  services.matterjs-server = {
    enable = true;
    listenAddress = "::1";
  };
  modules.impermanence.directories = [
    "/var/lib/private/matterjs-server"
    "/var/lib/hass"
  ];
  systemd.tmpfiles.rules = [
    "d /var/lib/private 0700 root root -"
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # mDNS
    5540 # Matter
  ];

  # Home Assistant
  services.home-assistant = {
    enable = true;
    extraComponents = [ "matter" ];
    config = {
      homeassistant = { };
    };
  };
  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant
  ];

  # Set up hardware
  imports = [ ./hardware-configuration.nix ];
}
