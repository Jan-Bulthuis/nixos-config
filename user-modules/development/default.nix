{ ... }:

{
  imports = [
    ./ide/mathematica.nix
    ./ide/matlab.nix
    # TODO: Move languages to make clear it is just IDE configuration
    # Languages should be installed with devShells, however the IDE must be configured globally
    ./language/cpp.nix
    ./language/haskell.nix
    ./language/js.nix
    ./language/jupyter.nix
    ./language/nix.nix
    ./language/python.nix
    ./language/rust.nix
    ./language/tex.nix
    ./utility/docker.nix
  ];
}
