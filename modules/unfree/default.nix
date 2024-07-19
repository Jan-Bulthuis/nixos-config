{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.unfree;
in
{
  options.modules.unfree = {
    enable = mkEnableOption "unfree";
    allowedPackages = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (getName pkg) cfg.allowedPackages;
  };
}
