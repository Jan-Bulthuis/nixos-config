{
  nixpkgs,
  flake-utils,
  ...
}:

let
  imports = [
    ./shell.nix
    ./languages/python.nix
    ./languages/rust.nix
    ./utilities/cuda.nix
    ./utilities/jupyter.nix
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
        libPackages = evaluated.libPackages pkgs;
        shell = recUpdate {
          env = evaluated.env // {
            LD_LIBRARY_PATH = (nixpkgs.lib.mkIf (libPackages != [ ]) (nixpkgs.lib.makeLibraryPath libPackages));
          };
          packages = evaluated.packages ++ (evaluated.extraPackages pkgs) ++ libPackages;
        } evaluated.override;
      in
      {
        devShells.default = pkgs.mkShell shell;
      }
    ));
}
