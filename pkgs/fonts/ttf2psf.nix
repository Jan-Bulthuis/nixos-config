{
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation {
  pname = "ttf2psf";
  version = "1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "NateChoe1";
    repo = "ttf2psf";
    rev = "8db09d05385f595c320eccae4c48ff4393ca5bde";
    sha256 = "A";
  };

  unpackPhase = ''
    true
  '';

  buildInputs = with pkgs; [
    tree
  ];

  buildPhase = ''
    tree > tree.txt
  '';

  installPhase = ''
    install -Dm644 -t $out/debug tree.txt
  '';
}
