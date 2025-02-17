{
  config,
  lib,
  ...
}:

with lib;
{
  options.modules.steam = {
    enable = mkEnableOption "steam";
  };

  config = mkIf config.modules.steam.enable {
    # Steam must be installed systemwide as of time of writing
  };
}
