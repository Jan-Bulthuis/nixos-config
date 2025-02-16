{ lib, ... }:

with lib;
{
  options.systemwide = mkOption {
    type = types.attrsOf types.anything;
    default = { };
    description = "Systemwide configuration required for user-specific settings.";
  };
}
