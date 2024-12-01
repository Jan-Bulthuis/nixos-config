{
  lib,
  config,
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation rec {
  pname = "wqy-bitmapsong-pcf";
  version = "1.0.0-RC1";

  src = pkgs.fetchurl {
    url = "mirror://sourceforge/wqy/${pname}-${version}.tar.gz";
    # hash = "sha256-r2Vf7ftJCqu7jOc2AqCKaoR/r8eNw2P/OQGqbDOEyl0=";
    hash = "sha256-0uvwkRUbvJ0remTnlP8dElRjaBVd6iukNYBTE/CTO7s=";
  };

  buildInputs = [ pkgs.fontforge ];
  buildPhase = ''
    newName() {
    test "''${1:5:1}" = i && _it=Italic || _it=
    case ''${1:6:3} in
        400) test -z $it && _weight=Medium ;;
        700) _weight=Bold ;;
    esac
    _pt=''${1%.pcf}
    _pt=''${_pt#*-}
    echo "WenQuanYi_Bitmap_Song$_weight$_it$_pt"
    }

    for i in *.pcf; do
    fontforge -lang=ff -c "Open(\"$i\"); Generate(\"$(newName $i).otb\")"
    done
  '';
  installPhase = ''
    install -Dm644 *.otb -t $out/share/fonts/
  '';
}
