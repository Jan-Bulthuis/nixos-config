{ ... }:

{
  imports = [
    ./ide/mathematica.nix
    ./ide/matlab.nix
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
