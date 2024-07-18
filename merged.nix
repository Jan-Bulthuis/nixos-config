# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  # nixvim = import (builtins.fetchGit {
  #   url = "https://github.com/nix-community/nixvim";
  # });
  # stylix = import (pkgs.fetchFromGitHub {
  #   owner = "danth";
  #   repo = "stylix";
  #   rev = "1ff9d37d27377bfe8994c24a8d6c6c1734ffa116";
  #   sha256 = "0dz8h1ga8lnfvvmvsf6iqvnbvxrvx3qxi0y8s8b72066mqgvy8y5";
  # });

  fontInstallPhase = ''
    runHook preInstall

    install -Dm644 *.ttc -t $out/share/fonts/

    runHook postInstall
  '';

  my-wqy-zenhei = pkgs.stdenv.mkDerivation rec {
    pname = "wqy-zenhei";
    version = "0.9.45";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/wqy/${pname}-${version}.tar.gz";
      hash = "sha256-5LfjBkdb+UJ9F1dXjw5FKJMMhMROqj8WfUxC8RDuddY=";
    };

    installPhase = fontInstallPhase;
  };

  my-wqy-microhei = pkgs.stdenv.mkDerivation rec {
    pname = "wqy-microhei";
    version = "0.2.0-beta";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/wqy/${pname}-${version}.tar.gz";
      hash = "sha256-KAKsgCOqNqZupudEWFTjoHjTd///QhaTQb0jeHH3IT4=";
    };

    installPhase = fontInstallPhase;
  };

  my-wqy-bitmapsong = pkgs.stdenv.mkDerivation rec {
    pname = "wqy-bitmapsong-pcf";
    version = "1.0.0-RC1";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/wqy/${pname}-${version}.tar.gz";
      #hash = "sha256-r2Vf7ftJCqu7jOc2AqCKaoR/r8eNw2P/OQGqbDOEyl0=";
      hash = "sha256-0uvwkRUbvJ0remTnlP8dElRjaBVd6iukNYBTE/CTO7s=";
    };

    buildInputs = [ pkgs.fontforge ];
    buildPhase = ''
      newName() {
        test "''${1:5:1}" = i && _it=Italic || _it=
        case ''${1:6:3} in
          400) test -z $it && _weight=Medium ;;
          700) _weight=Bold ;;
        esac
        _pt=''${1%.pcf}
        _pt=''${_pt#*-}
        echo "WenQuanYi_Bitmap_Song$_weight$_it$_pt"
      }

      for i in *.pcf; do
        fontforge -lang=ff -c "Open(\"$i\"); Generate(\"$(newName $i).otb\")"
      done
    '';
    installPhase = ''
      install -Dm644 *.otb -t $out/share/fonts/
    '';
  };
in {
  # imports =
  #   [
  #     # Include home manager
  #     # <home-manager/nixos>
  #   ];

  # # Enable NUR
  # nixpkgs.config.packageOverrides = pkgs: {
  #   # TODO: Pin the version
  #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #     inherit pkgs;
  #   };
  # };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    tmp.cleanOnBoot = true;

    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.checkJournalingFS = false;

    plymouth = {
      enable = false;
      theme = "text";
    };

    kernelParams = [
      "quiet"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "video=efifb:nobgrt"
      "bgrt_disable"
    ];
  };

  # Set up console
  # console = {
  #   keyMap = "us";
  # };

  # Set up networking
  # networking.wireless.userControlled.enable = true;
  # networking.hostName = "20212060"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.wireless.allowAuxiliaryImperativeNetworks = true;  

  nixpkgs.config.allowUnfree = true;

  # Set up graphics
  hardware.graphics.enable32Bit = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  # Set up tailscale
  # services.tailscale = {
  #   enable = true;
  #   useRoutingFeatures = "client";
  # };

  # Set time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  # Enable sound
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   pulse.enable = true;
  # };

  # Set up input
  services.libinput.enable = true;

  # Display manager
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --greeting \"Hewwo! >_< :3\" --time --cmd river --asterisks";
  #       user = "greeter";
  #     };
  #   };
  # };

  # PAM setup
  # security.pam.services.waylock = {};

  # Enable programs
  # programs.river.enable = true;

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };

  # Gamer moment
  # programs.steam.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jan = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # home-manager.backupFileExtension = "bak";

  # Global neovim
  # pr` 

  # dconf
  programs.dconf.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    my-wqy-zenhei
    my-wqy-microhei
    my-wqy-bitmapsong
    cozette
    #uw-ttyp0
    #ucs-fonts
    dina-font # Cool but too small :(
    #unifont # Replace with Kissinger2
    #unifont_upper # Replace with Kissinger 2
    (nerdfonts.override { fonts = ["NerdFontsSymbolsOnly"]; })
  ];
  fonts.fontconfig.defaultFonts = {
    serif = [
      "DejaVu Serif"
    ];
    sansSerif = [
      "DejaVu Sans"
    ];
    monospace = [
      "Dina"
    ];
    emoji = [
      "CozetteVector"
      "Noto Color Emoji"
    ];
  };
  fonts.fontconfig.localConf = ''
    <alias>
      <family>Dina</family>
      <prefer>
        <family>Dina</family>
        <family>Cozette</family>
        <family>CozetteVector</family>
        <family>Fixed</family>
        <family>Symbols Nerd Font Mono</family>
        <family>WenQuanYi Bitmap Song</family>
      </prefer>
    </alias>
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    wget
    curl
    brightnessctl
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # system.stateVersion = "24.05"; # Did you read the comment?
}
