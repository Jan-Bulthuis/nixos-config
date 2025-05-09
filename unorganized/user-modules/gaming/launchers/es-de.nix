{
  lib,
  config,
  pkgs,
  system,
  ...
}:

with lib;
let
  cfg = config.modules.es-de;
in
{
  options.modules.es-de = {
    enable = mkEnableOption "Emulation Station Desktop Edition";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      emulationstation-de
    ];

    home.sessionVariables = {
      ESDE_APPDATA_DIR = "$HOME/.config/ES-DE";
    };

    # TODO: Remove exception once no longer required by es-de
    nixpkgs.config.permittedInsecurePackages = [
      "freeimage-3.18.0-unstable-2024-04-18"
    ];

    # TODO: Remove once emulationstation-de fixes the issue
    # TODO: If not fixed, at least pin the specific commit properly
    # nixpkgs.overlays =
    #   let
    #     pkgs-stable = import (fetchTarball {
    #       url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz";
    #       sha256 = "1wr1xzkw7v8biqqjcr867gbpqf3kibkgly36lcnhw0glvkr1i986";
    #     }) { inherit system; };
    #   in
    #   [
    #     (final: prev: {
    #       libgit2 = pkgs-stable.libgit2;
    #     })
    #   ];
  };
}
