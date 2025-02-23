{ pkgs, ... }:

with pkgs;
rustPlatform.buildRustPackage {
  pname = "nixgreety";
  version = "master";

  src = fetchFromGitea {
    domain = "git.bulthuis.dev";
    owner = "Jan";
    repo = "nixgreety";
    rev = "4b5f812e95f6359ce61aef685005dc4013f0fb5f";
    hash = "sha256-/eikqX/2byDi04v1XvsBVva1Vs7OGLl/cC/Vrq+QF9A=";
  };

  cargoHash = "sha256-pklKVzYoChRqPZ/D3BsMGnaBFd615TKbvoAy7iU8UtA=";

  useFetchCargoVendor = true;
}
