{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.modules.steam = {
    enable = mkEnableOption "steam";
  };
}