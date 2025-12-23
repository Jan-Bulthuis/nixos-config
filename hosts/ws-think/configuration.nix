{
  inputs,
  pkgs,
  config,
  ...
}:

{
  # State version
  system.stateVersion = "24.05";

  # Machine hostname
  networking.hostName = "ws-think";

  # Set up users
  sops.secrets."passwords/jan-hashed" = {
    sopsFile = "${inputs.secrets}/secrets/ws-think.enc.yaml";
    neededForUsers = true;
  };
  users.mutableUsers = false;
  users.users.Jan = {
    hashedPasswordFile = config.sops.secrets."passwords/jan-hashed".path;
    # Extra admin groups
    # TODO: Streamline setup of this
    extraGroups = [
      "wheel"
      "wireshark"
      "podman"
      "libvirtd"
    ];
  };

  # Set up impermanence
  modules.impermanence = {
    enable = true;
    resetScript = ''
      # Revert to the blank state for the root directory
      zfs rollback -r tank/root@blank
    '';
  };

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
        "udp://51819:10.10.40.100:51820"
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

  # Enable Gnome Remote Desktop
  services.gnome.gnome-remote-desktop.enable = true;
  systemd.services."gnome-remote-desktop".wantedBy = [ "graphical.target" ];
  systemd.services."gnome-remote-desktop".preStart =
    let
      credDir = "/var/lib/gnome-remote-desktop/.local/share/gnome-remote-desktop";
      credPath = "${credDir}/credentials.ini";
      credFile = pkgs.writeText "gnome-remote-desktop-credentials" ''
        [RDP]
        credentials={'username': <'remote'>, 'password': <'remote'>}
      '';
      script = pkgs.writeScript "gnome-remote-desktop-setup" ''
        mkdir -p ${credDir}
        touch ${credPath}
        chown gnome-remote-desktop:gnome-remote-desktop ${credPath}
        chmod 600 ${credPath}
        cat ${credFile} > ${credPath}
      '';
    in
    "${script}";
  environment.etc."gnome-remote-desktop/grd.conf" = {
    text = ''
      [RDP]
      port=3389
      tls-key=/run/secrets/gnome-remote-desktop/tls-key
      tls-cert=/run/secrets/gnome-remote-desktop/tls-crt
      enabled=true
    '';
  };
  networking.firewall = {
    allowedTCPPorts = [
      3389
      3390
    ];
    allowedUDPPorts = [
      3389
      3390
    ];
  };
  sops.secrets."gnome-remote-desktop/tls-key" = {
    sopsFile = "${inputs.secrets}/secrets/ws-think.enc.yaml";
    owner = config.users.users.gnome-remote-desktop.name;
    group = config.users.users.gnome-remote-desktop.group;
  };
  sops.secrets."gnome-remote-desktop/tls-crt" = {
    sopsFile = "${inputs.secrets}/secrets/ws-think.enc.yaml";
    owner = config.users.users.gnome-remote-desktop.name;
    group = config.users.users.gnome-remote-desktop.group;
  };

  # Set up hardware
  imports = [ ./hardware-configuration.nix ];
}
