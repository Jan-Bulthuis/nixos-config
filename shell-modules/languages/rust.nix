{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  rustPackage = pkgs.rustc;
in
{
  options.rust = {
    enable = mkEnableOption "Rust";
    # TODO: Add option to specify toolchain file
    # See https://ayats.org/blog/nix-rustup
  };

  config = mkIf config.rust.enable {
    packages = [
      bacon
      evcxr
      cargo

      rustPackage

      # TODO: Might be needed for bindgen
      # rustPlatform.bindgenHook
      # pkg-config
    ];

    # env.RUST_SRC_PATH = "${rustPackage}/lib/rustlib/src/rust/library";
  };
}
