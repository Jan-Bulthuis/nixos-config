{
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation rec {
  pname = "wqy-microhei";
  version = "0.2.0-beta";

  src = pkgs.fetchurl {
    url = "mirror://sourceforge/wqy/${pname}-${version}.tar.gz";
    hash = "sha256-KAKsgCOqNqZupudEWFTjoHjTd///QhaTQb0jeHH3IT4=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttc -t $out/share/fonts/

    runHook postInstall
  '';
}
