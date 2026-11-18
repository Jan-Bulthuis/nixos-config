{
  lib,
  fetchFromGitHub,
  rustPlatform,
  helix,
  helix-unwrapped,
}:

# Helix from git, built with nixpkgs' packaging instead of the upstream flake. The
# flake fetches every tree-sitter grammar without a hash at evaluation time. Here
# they are pinned in grammars.json, so they are fetched once and kept in the store.
#
# To update: change rev and hash, set cargoHash to lib.fakeHash, build and copy the
# expected hash, then run ./update-grammars.sh.
let
  unwrapped = helix-unwrapped.overrideAttrs (
    final: prev: {
      version = "25.07.1-unstable-${final.src.rev}";

      src = fetchFromGitHub {
        owner = "helix-editor";
        repo = "helix";
        rev = "f6f3eb1fe4a73933466f30175843059a4381a985";
        hash = "sha256-yfNBfV6HWAQU/xZXwrFoedsSYsDmCDIlTHRxAZI6teY=";
      };

      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit (final) src;
        name = "${final.pname}-${final.version}-vendor";
        hash = lib.fakeHash;
      };

      # The mdbook 0.5 patch from nixpkgs targets the release
      patches = [ ];

      # Report the commit in `hx --version`
      env = prev.env // {
        HELIX_NIX_BUILD_REV = final.src.rev;
      };

      # The version check expects the release version string
      doInstallCheck = false;
    }
  );
in
(helix.override {
  helix-unwrapped = unwrapped;
  lockedGrammars = lib.importJSON ./grammars.json;
}).overrideAttrs
  { passthru.unwrapped = unwrapped; }
