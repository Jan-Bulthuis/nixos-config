{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  # State version
  system.stateVersion = "24.05";

  # Machine hostname
  networking.hostName = "ws-think";

  # Admin users
  users.users.jan.extraGroups = [
    "wheel"
    "wireshark"
    "podman"
    "libvirtd"
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

  services.netbird = {
    enable = true;
  };

  # SSH X11 forwarding
  programs.ssh.forwardX11 = true;

  # Enable older samba versions
  services.samba = {
    enable = true;
    settings = {
      global = {
        "invalid users" = [ "root" ];
        "passwd program" = "/run/wrappers/bin/passwd %u";
        "security" = "user";
        "client min protocol" = "NT1";
      };
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
  programs.virt-manager.enable = true;

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

  # Enable flatpak
  services.flatpak.enable = true;

  # Module setup
  modules = {
    profiles.laptop.enable = true;
  };

  # Set up podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    autoPrune.enable = true;
  };

  # Set up hardware
  imports = [ ./hardware-configuration.nix ];
}
