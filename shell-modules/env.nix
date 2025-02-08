{ lib, ... }:

with lib;
{
  options = {
    env = mkOption {
      type = types.attrsOf types.str;
      default = [ ];
    };
  };
}
