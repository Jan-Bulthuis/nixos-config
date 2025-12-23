{
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

      impermanence = {
        files = [
          "/etc/machine-id"
          "/etc/zfs/zpool.cache" # TODO: Move to zfs module?
        ];
        directories = [
          "/var/log/journal"
          "/var/lib/nixos"
          "/var/lib/systemd"
        ];
      };

      # TODO: Remove the secrets module and use sops directly?
      secrets = {
        enable = true;
        secrets = {
          "ssh-keys/deploy-priv" = {
            path = "/root/.ssh/id_ed25519";
          };
        };
      };
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
