{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.neovim;
in {
  options.modules.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}