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

  # The rest of the configuration is in a systemwide module
}
