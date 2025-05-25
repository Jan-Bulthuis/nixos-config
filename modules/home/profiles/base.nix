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
    enable = mkEnableOption "Base home-manager profile";
  };

  config = mkIf cfg.enable {
    modules = {
      # btop.enable = true;
      direnv.enable = true;
      fish.enable = true;
      # scripts.enable = true;

      # Development
      # neovim.enable = true;

      # Languages
      nix.enable = true;
    };
  };
}
