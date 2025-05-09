{ pkgs, ... }:

with pkgs;
rustPlatform.buildRustPackage {
  pname = "nixgreety";
  version = "master";

  src = fetchFromGitea {
    domain = "git.bulthuis.dev";
    owner = "Jan";
    repo = "nixgreety";
    rev = "c7278a910a0238a53f23fe9a0ae881802a4bcb31";
    hash = "sha256-kZB+iEFIDJ8pOJetu4Isu4oaktgIn14D4PcpDXLOXA8=";
  };

  cargoHash = "sha256-pklKVzYoChRqPZ/D3BsMGnaBFd615TKbvoAy7iU8UtA=";

  useFetchCargoVendor = true;
}
