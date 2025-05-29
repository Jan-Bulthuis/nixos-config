{ flake, ... }:

{
  # State version
  system.stateVersion = "24.05";

  # Machine hostname
  networking.hostName = "20212060";

  # Admin users
  users.users.jan.extraGroups = [
    "wheel"
    "wireshark"
  ];

  # Enable virtualisation for VMs
  virtualisation.libvirtd.enable = true;

  # Enable wireshark
  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    usbmon.enable = true;
  };

  # Set up wstunnel client
  services.wstunnel = {
    enable = true;
    clients.wg-tunnel = {
      connectTo = "wss://tunnel.bulthuis.dev:443";
      localToRemote = [
        "udp://51820:10.10.40.100:51820"
      ];
    };
  };

  # Module setup
  modules = {
    profiles.laptop.enable = true;
  };

  imports = [
    ./hardware-configuration.nix
  ];
}
