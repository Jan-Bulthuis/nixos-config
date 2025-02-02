{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.base;
in
{
  options.modules.base = {
    enable = mkEnableOption "base";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Add base linux utilities
      git
      wget
      curl
      dig
      procps
      wireguard-tools
      usbutils
      pciutils
      zip
      unzip

      # TODO: MOVE
      quickemu # TODO: Reenable once building this is fixed
      pdftk

      # TODO: Move to USB module
      # usbutils
      # udiskie
      # udisks
    ];

    security.krb5 = {
      enable = true;
      settings = {
        libdefaults = {
          rdns = false;
        };
        realms = {
          "GEWISWG.GEWIS.NL" = {
            kdc = [
              "https://gewisvdesktop.gewis.nl/KdcProxy"
            ];
          };
        };
      };
    };

    modules = {
      # Enable base modules
      clean-tmp.enable = true;
      fontconfig.enable = true;
      neovim.enable = true;
      systemd-boot.enable = true;
      tuigreet.enable = true; # TODO: Re-enable
    };

    # TODO: Remove everything below, it is here out of convenience and should be elsewhere
    # networking.nameservers = [
    #   "9.9.9.9"
    #   "149.112.112.112"
    # ];
    # programs.captive-browser.enable = true;
    services.resolved = {
      enable = true;
    };
    networking.firewall.enable = true;
    programs.dconf.enable = true;
    services.libinput.enable = true;
    modules.unfree.enable = true;
    modules.unfree.allowedPackages = [
      "nvidia-x11"
      "nvidia-settings"
    ];
    nix.settings.experimental-features = "nix-command flakes";
    # networking.useDHCP = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 10000;
        to = 11000;
      }
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 10000;
        to = 11000;
      }
    ];

    # TODO: Move to USB module
    # services.gvfs.enable = true;
    services.udisks2.enable = true;

    # TODO: Remove?
    # Temporarily disable nvidia dgpu
    # boot.extraModprobeConfig = ''
    #   blacklist nouveau
    #   options nouveau modeset=0
    # '';
    # services.udev.extraRules = ''
    #   # Remove NVIDIA USB xHCI Host Controller devices, if present
    #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

    #   # Remove NVIDIA USB Type-C UCSI devices, if present
    #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

    #   # Remove NVIDIA Audio devices, if present
    #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

    #   # Remove NVIDIA VGA/3D controller devices
    #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
    # '';
    # boot.blacklistedKernelModules = [
    #   "nouveau"
    #   "nvidia"
    # ];

    # TODO: Move to module
    # Adds gnome as DE
    # modules.greetd.enable = lib.mkForce false;
    # modules.tuigreet.enable = lib.mkForce false;
    # services.xserver = {
    #   enable = true;
    #   displayManager.gdm.enable = true;
    #   desktopManager.gnome.enable = true;
    # };
  };
}
