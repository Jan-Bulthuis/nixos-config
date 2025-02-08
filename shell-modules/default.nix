{ nixpkgs, flake-utils, ... }:

let
  imports = [
    ./languages/python.nix
  ];
in
{

  mkShell =
    attrs:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        modules = [
          attrs
        ] ++ imports;
        evaluated = nixpkgs.lib.evalModules { inherit modules; };
      in
      {
        devShells.default = pkgs.mkShell {
          TEST_ENV = builtins.trace evaluated.config "HELLO";
        };
      }
    ));
}
