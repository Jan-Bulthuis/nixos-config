{ lib, ... }:

with lib;
{
  options = {
    env = mkOption {
      type = types.attrsOf types.str;
      default = [ ];
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Packages to install";
    };
  };
}
