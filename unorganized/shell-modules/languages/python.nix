{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  packages = config.python.packages;
  pythonPackage = pkgs.python3.withPackages packages;
in
{
  options.python = {
    enable = mkEnableOption "Python";
    packages = mkOption {
      type = types.functionTo (types.listOf types.package) // {
        merge =
          loc: defs: p:
          lib.concatMap (def: (def.value p)) defs;
      };
      default = p: [ ];
      description = "Python packages to install";
    };
    # TODO: Add option to directly read from requirements.txt, maybe with mach-nix
  };

  config = mkIf config.python.enable {
    packages = [
      pythonPackage
    ];

    env.PYTHONINTERPRETER = "${pythonPackage}/bin/python";
  };
}
