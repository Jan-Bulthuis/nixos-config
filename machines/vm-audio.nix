{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    # Import environment
    ./vm-base.nix
  ];

  config = {
    # Machine hostname
    networking.hostName = "vm-audio";

    # Enabled modules
    modules = {
      pipewire.enable = true;
      spotifyd.enable = true;
    };

    # Install system packages
    environment.systemPackages = with pkgs; [
      carla
      wprs
      xpra
      xwayland
      alsa-utils
      pulsemixer
      adwaita-icon-theme

      # Add LV2 plugins
      lsp-plugins
      airwindows-lv2
      distrho-ports
      cardinal
    ];

    # Setup dependencies
    environment.variables.LD_LIBRARY_PATH = lib.mkForce "${lib.makeLibraryPath (
      with pkgs;
      [
        cairo
        pipewire.jack
      ]
    )}";
    qt = {
      enable = true;
      style = "adwaita";
    };
    xdg.icons = {
      enable = true;
      fallbackCursorThemes = [ "Adwaita" ];
    };

    # User for audio mixing
    users.users.mixer = {
      isNormalUser = true;
      group = "mixer";
      extraGroups = [ "systemd-journal" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKxoQSxfYqf9ITN8Fhckk8WbY4dwtBAXOhC9jxihJvq jan@bulthuis.dev"
      ];
    };
    users.groups.mixer = { };
    users.groups.audio = {
      members = [
        "mixer"
        "local"
      ];
    };

    # wprsd service
    systemd.user.services.wprsd = {
      description = "wprsd Service";
      wantedBy = [ "default.target" ];
      after = [ "network.target" ];
      unitConfig = {
        ConditionUser = "mixer";
      };
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash -l -c wprsd --enable-xwayland=true"; # Use login shell to inherit environment
        Environment = "\"RUST_BACKTRACE=full\"";
        Restart = "always";
        RestartSec = 5;
      };
    };

    # Dedicate more memory to network interfaces
    boot.kernel.sysctl = {
      "net.core.rmem_default" = 1048576;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_default" = 1048576;
      "net.core.wmem_max" = 16777216;
      "net.core.optmem_max" = 65536;
      "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
      "net.ipv4.tpc_wmem" = "4096 65536 16777216";
      "net.ipv4.udp_rmem_min" = 8192;
      "net.ipv4.udp_wmem_min" = 8192;
    };

    # Create null sink for spotifyd
    services.pipewire.extraConfig.pipewire."91-null-sinks" = {
      "context.objects" = [
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "SpotifyD-Proxy";
            "node.description" = "Proxy for SpotifyD";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
          };
        }
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "AnalogIn-Proxy";
            "node.description" = "Proxy for the analog input";
            "media.class" = "Audio/Source/Virtual";
            "audio.position" = "FL,FR";
          };
        }
      ];
    };
  };
}
