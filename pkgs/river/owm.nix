{
  lib,
  config,
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "owm";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "justinlovinger";
    repo = pname;
    rev = "master";
    sha256 = "sha256-l9usg0XGtghCX8elvjExYJgMuMGeujOoS2n1hCQkN78=";
  };

  cargoSha256 = "";
}
