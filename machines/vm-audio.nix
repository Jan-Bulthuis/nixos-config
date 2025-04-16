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
    ];

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

    # wprsd service
    systemd.user.services.wprsd = {
      description = "wprsd Service";
      wantedBy = [ "default.target" ];
      after = [ "network.target" ];
      unitConfig = {
        ConditionUser = "mixer";
      };
      serviceConfig = {
        # ExecStart = "${pkgs.wprs}/bin/wprsd --enable-xwayland=true --xwayland-xdg-shell-path=${pkgs.wprs}/bin/xwayland-xdg-shell";
        ExecStart = "${pkgs.bash}/bin/bash -l -c wprsd --enable-xwayland=true"; # Use login shell to inherit environment
        Environment = "\"RUST_BACKTRACE=full\"";
        Restart = "always";
        RestartSec = 5;
      };
    };

    # Boot option for soundcard
    # boot.kernelParams = [ "snd-intel-dspcfg.dsp_driver=1" ];
    boot.kernelPackages = pkgs.linuxPackages_6_9;
  };
}
