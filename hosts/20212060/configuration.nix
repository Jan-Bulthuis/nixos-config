{ inputs, pkgs, ... }:

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

  # Set up kerberos
  security.krb5 = {
    enable = true;
    settings = {
      libdefaults = {
        rdns = false;
      };
      realms = (inputs.secrets.gewis.krb5Realm);
    };
  };

  # TODO: Remove once laptop is properly integrated into domain
  programs.ssh = {
    package = pkgs.openssh_gssapi;
    extraConfig = ''
      GSSAPIAuthentication yes
    '';
  };

  # Enable virtualisation for VMs
  virtualisation.libvirtd.enable = true;

  # Enable wireshark
  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    usbmon.enable = true;
  };

  # Enable Nix-LD
  programs.nix-ld = {
    enable = true;
  };

  # Set up wstunnel client
  services.wstunnel = {
    enable = true;
    clients.wg-tunnel = {
      connectTo = "wss://tunnel.bulthuis.dev:443";
      settings.local-to-remote = [
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
