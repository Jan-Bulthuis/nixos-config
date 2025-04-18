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
      waypipe

      # Add LV2 plugins
      lsp-plugins
      airwindows-lv2
      distrho-ports
      cardinal
    ];

    # Setup firewall
    networking.firewall = {
      allowedTCPPorts = [
        22752
        15151
      ];
      allowedUDPPorts = [
        22752
        15151
      ];
    };

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

    # Xpra service
    systemd.user.services.xpra = {
      description = "Xpra Service";
      wantedBy = [ "default.target" ];
      after = [
        "network.target"
      ];
      unitConfig = {
        ConditionUser = "mixer";
      };
      serviceConfig = {
        ExecStart = "${pkgs.xpra}/bin/xpra start :7 --bind-tcp=0.0.0.0:15151 --daemon=no";
        Restart = "always";
        RestartSec = 5;
      };
    };

    # Carla service
    systemd.user.services.carla = {
      description = "Carla Service";
      wantedBy = [ "default.target" ];
      after = [
        "network.target"
        "sound.target"
      ];
      requires = [
        "xpra.service"
      ];
      unitConfig = {
        ConditionUser = "mixer";
      };
      serviceConfig = {
        ExecStart = "DISPLAY=:7 ${pkgs.carla}/bin/carla -platform xcb /home/mixer/Default.carxp";
        Restart = "always";
        RestartSec = 5;
      };
    };

    # Create null sinks
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
