{
  nixpkgs,
  flake-utils,
  ...
}:

let
  imports = [
    ./shell.nix
    ./languages/python.nix
    ./utilities/cuda.nix
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
        evaluated =
          (nixpkgs.lib.evalModules {
            modules = [ attrs ] ++ imports;
            specialArgs = {
              pkgs = pkgs;
            };
          }).config;
        recUpdate = nixpkgs.lib.recursiveUpdate;
        shell = recUpdate {
          env = evaluated.env;
          packages = evaluated.packages ++ (evaluated.extraPackages pkgs);
        } evaluated.override;
      in
      {
        devShells.default = pkgs.mkShell shell;
      }
    ));
}
