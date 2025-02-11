{
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation {
  pname = "dina-font";
  version = "1.0.0";

  unpackPhase = "true";

  buildInputs = [
    pkgs.fontforge
    pkgs.dina-font
    pkgs.wqy-bitmapsong
    pkgs.tree
  ];

  # TODO: Fix or remove package
  buildPhase = ''
    tree > debug.txt
  '';
  installPhase = ''
    install -Dm644 $out/debug.txt
  '';
}
