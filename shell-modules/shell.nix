{ lib, ... }:

with lib;
{
  options = {
    env = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Packages to install";
    };

    extraPackages = mkOption {
      type = types.functionTo (types.listOf types.package) // {
        merge =
          loc: defs: p:
          lib.concatMap (def: (def.value p)) defs;
      };
      default = p: [ ];
      description = "Extra packages to install";
    };

    libPackages = mkOption {
      type = types.functionTo (types.listOf types.package) // {
        merge =
          loc: defs: p:
          lib.concatMap (def: (def.value p)) defs;
      };
      default = p: [ ];
      description = "Packages to install and add to library path";
    };

    override = mkOption {
      type = types.attrs;
      default = { };
      description = "Settings in the mkShell call to override";
    };
  };
}
