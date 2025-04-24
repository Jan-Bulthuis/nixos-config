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
      xpra
      alsa-utils
      pulsemixer
      adwaita-icon-theme
      open-stage-control
      carla_osc_bridge

      # Add LV2 plugins
      lsp-plugins
      airwindows-lv2
      distrho-ports
      cardinal
      calf
    ];

    # Setup firewall
    networking.firewall = {
      allowedTCPPorts = [
        8080
        15151
        22752
      ];
      allowedUDPPorts = [
        8080
        15151
        22752
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
      ];
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
        ExecStart = "${pkgs.carla}/bin/carla -platform xcb /home/mixer/Default.carxp";
        Environment = "\"DISPLAY=:7\"";
        Restart = "always";
        RestartSec = 5;
      };
    };

    # Carla service
    systemd.user.services.carla-bridge = {
      description = "Carla OSC Bridge";
      wantedBy = [ "default.target" ];
      after = [
        "network.target"
        "sound.target"
      ];
      requires = [
        "carla.service"
      ];
      unitConfig = {
        ConditionUser = "mixer";
      };
      serviceConfig = {
        ExecStart = "${pkgs.carla_osc_bridge}/bin/carla_osc_bridge --clients \"127.0.0.1:8080\"";
        Restart = "always";
        RestartSec = 5;
      };
    };

    # Open stage control service
    systemd.user.services.osc = {
      description = "OSC Service";
      wantedBy = [ "default.target" ];
      after = [
        "network.target"
      ];
      requires = [
        "carla.service"
      ];
      unitConfig = {
        ConditionUser = "mixer";
      };
      serviceConfig = {
        ExecStart = "${pkgs.open-stage-control}/bin/open-stage-control --no-gui --send 127.0.0.1:10402 --load /home/mixer/open-stage-control/session.json --theme /home/mixer/open-stage-control/theme.css";
        Environment = "\"ELECTRON_RUN_AS_NODE=1\"";
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
            "node.name" = "Speaker-Proxy";
            "node.description" = "Proxy for Speaker Output";
            "media.class" = "Audio/Sink";
            "audio.position" = "L,R";
          };
        }
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "Headphone-Proxy";
            "node.description" = "Proxy for Headphone Output";
            "media.class" = "Audio/Sink";
            "audio.position" = "L,R";
          };
        }
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "SpotifyD-Proxy";
            "node.description" = "Proxy for SpotifyD";
            "media.class" = "Audio/Sink";
            "audio.position" = "L,R";
          };
        }
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "AnalogIn-Proxy";
            "node.description" = "Proxy for the analog input";
            "media.class" = "Audio/Source/Virtual";
            "audio.position" = "L,R";
          };
        }
      ];
    };
  };
}
