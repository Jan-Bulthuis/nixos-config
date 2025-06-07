{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.profiles.jan;
in
{
  options.modules.profiles.jan = {
    enable = mkEnableOption "Jan's personal profile";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-still
      remmina
      thunderbird
      signal-desktop
      prusa-slicer
      freecad-wayland
      inkscape
      ente-auth
      carla
      winbox
      whatsapp-for-linux
      discord
      steam
      spotify
      # feishin # TODO: Fix or replace as insecure
      eduvpn-client
      river # TODO: Move
      ryubing
      bottles
      prismlauncher
      foliate
      wireshark
      obsidian
    ];

    modules = {
      profiles.gnome.enable = true;

      # Gaming
      # retroarch.enable = true;
      # ryujinx.enable = true;

      # Tools
      git = {
        enable = true;
        user = "Jan-Bulthuis";
        email = "git@bulthuis.dev";
        # TODO: Move
        ignores = [
          ".envrc"
          ".direnv"
          "flake.nix"
          "flake.lock"
        ];
      };
      bitwarden.enable = true;
      xpra = {
        enable = true;
        hosts = [
          "mixer@10.20.60.251"
        ];
      };

      # Development
      # docker.enable = true;
      # matlab.enable = true;
      mathematica.enable = true;

      # Languages
      haskell.enable = false;
      js.enable = true;
      nix.enable = true;
      rust.enable = true;
      python.enable = true;
      cpp.enable = true;
      tex.enable = true;
      jupyter.enable = false;
    };
  };
}
