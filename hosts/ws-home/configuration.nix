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
    domain.enable = false;
  };

  # Let the kernel handle router advertisements, so the route to the
  # Thread network advertised by the OTBR gets installed
  networking.dhcpcd.IPv6rs = false;
  boot.kernel.sysctl = {
    "net.ipv6.conf.default.accept_ra_rt_info_max_plen" = 64;
    "net.ipv6.conf.eno1.accept_ra" = 1;
    "net.ipv6.conf.eno1.accept_ra_rt_info_max_plen" = 64;
  };

  # Matter controller
  services.matterjs-server = {
    enable = true;
    listenAddress = "::1";
  };
  modules.impermanence.directories = [
    "/var/lib/private/matterjs-server"
    {
      directory = "/var/lib/hass";
      user = "hass";
      group = "hass";
      mode = "0700";
    }
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
      http = {
        use_x_forwarded_for = true;
        # TODO: Narrow down to the address the internal gateway connects from
        trusted_proxies = [ "10.10.0.0/16" ];
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant
  ];

  # Set up hardware
  imports = [ ./hardware-configuration.nix ];
}
