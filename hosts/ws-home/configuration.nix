{
  config,
  inputs,
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
    "/var/lib/private/atticd"
    {
      directory = "/var/lib/hass";
      user = "hass";
      group = "hass";
      mode = "0700";
    }
  ];
  systemd.tmpfiles.rules = [
    "d /var/lib/private 0700 root root -"
    "d /persist/system/var/lib/private 0700 root root -"
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # mDNS
    5540 # Matter
  ];

  # Home Assistant
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "matter"
      "mobile_app"
      "otbr"
      "thread"
    ];
    config = {
      homeassistant = { };
      mobile_app = { };
      http = {
        use_x_forwarded_for = true;
        # TODO: Narrow down to the address the internal gateway connects from
        trusted_proxies = [ "10.10.0.0/16" ];
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant
    8080 # Attic
  ];

  # Attic binary cache, served as cache.ib.baksteeninc.net behind the reverse proxy
  sops.secrets."atticd/env".sopsFile = "${inputs.secrets}/secrets/ws-home.enc.yaml";
  services.atticd = {
    enable = true;
    environmentFile = config.sops.secrets."atticd/env".path;
    settings = {
      listen = "[::]:8080";
      api-endpoint = "https://cache.ib.baksteeninc.net/";
      compression.type = "zstd";
      garbage-collection = {
        interval = "12 hours";
        # Drop paths that have not been accessed for this long
        default-retention-period = "3 months";
      };
    };
  };

  # Set up hardware
  imports = [ ./hardware-configuration.nix ];
}
