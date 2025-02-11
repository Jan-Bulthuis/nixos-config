{
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation {
  pname = "dina-psfu";
  version = "1.0.0";

  # src = pkgs.fetchurl {
  #   url = "mirror://sourceforge/wqy/${pname}-${version}.tar.gz";
  #   # hash = "sha256-r2Vf7ftJCqu7jOc2AqCKaoR/r8eNw2P/OQGqbDOEyl0=";
  #   hash = "sha256-0uvwkRUbvJ0remTnlP8dElRjaBVd6iukNYBTE/CTO7s=";
  # };

  unpackPhase = "true";

  buildInputs = with pkgs; [
    dina-font
    bdf2psf
    tree
  ];
  buildPhase = ''
    tree > debug.txt
  '';
  installPhase = ''
    install -Dm644 $out/debug.txt
  '';
}
