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
    };

    # Install system packages
    environment.systemPackages = with pkgs; [
      carla
      wprs
      xwayland

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

    # Pipewire roc source
    services.pipewire.extraConfig.pipewire."60-roc-source" = {
      "context.modules" = [
        {
          "name" = "libpipewire-module-roc-source";
          "args" = {
            "fec.code" = "rs8m";
            "local.ip" = "0.0.0.0";
            "resampler.profile" = "medium";
            # sess.latency.msec = 10;
            "local.source.port" = 10001;
            "local.repair.port" = 10002;
            "source.name" = "Roc Source";
            "source.props.node.name" = "roc-source";
          };
        }
      ];
    };

    # Set firewall ports
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        10001
        10002
      ];
      allowedUDPPorts = [
        10001
        10002
      ];
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
  };
}
