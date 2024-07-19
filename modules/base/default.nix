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
    ];

    modules = {
      # Enable base modules
      clean-tmp.enable = true;
      fontconfig.enable = true;
      neovim.enable = true;
      systemd-boot.enable = true;
      tuigreet.enable = true;
      tailscale.enable = true;
    };

    # TODO: Remove everything below, it is here out of convenience and should be elsewhere
    programs.dconf.enable = true;
    services.libinput.enable = true;
    modules.unfree.enable = true;
    modules.unfree.allowedPackages = [
      "nvidia-x11"
      "nvidia-settings"
    ];
  };
}
