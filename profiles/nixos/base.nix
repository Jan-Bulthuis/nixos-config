{
  mkModule,
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.profiles.base;
in
{
  options.modules.profiles.base = {
    enable = mkEnableOption "base profile";
  };

  config = mkIf cfg.enable {
    modules = {
      bootloader.enable = mkDefault true;
      ssh.enable = mkDefault true;

      impermanence.directories = [
        "/var/lib/nixos"
      ];
    };

    # Localization
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";

    # Enable neovim
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable the usage of flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Clean tmp
    boot.tmp.cleanOnBoot = true;

    # Base packages
    environment.systemPackages = with pkgs; [
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
      tmux
    ];
  };
}
