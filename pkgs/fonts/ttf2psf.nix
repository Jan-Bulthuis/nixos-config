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
    sha256 = "v52TZp+GyXHBAMsIoHFA8ZIMPsDVls13WW29vpesCig=";
  };

  buildInputs = with pkgs; [
    pkg-config
    freetype
  ];

  buildPhase = ''
    make build/ttf2psf
  '';

  installPhase = ''
    install -Dm 755 -t $out/bin build/ttf2psf
    install -Dm 644 -t $out/share/ttf2psf data/*.*
    install -Dm 644 -t $out/share/ttf2psf/fontsets data/fontsets/*
  '';
}
