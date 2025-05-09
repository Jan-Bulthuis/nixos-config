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
    ];

    modules = {
      # Enable base modules
      clean-tmp.enable = true;
      neovim.enable = true;
      systemd-boot.enable = true;
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
    modules.unfree.enable = true;
    nix.settings.experimental-features = "nix-command flakes";
    nixpkgs.hostPlatform = "x86_64-linux";

    console.packages = [
      pkgs.dina-psfu
    ];
    console.font = "dina";
    console.earlySetup = true;
    boot.loader.timeout = 0;
  };
}
