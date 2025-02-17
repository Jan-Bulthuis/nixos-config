{
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation {
  pname = "dina-psfu";
  version = "1.0.0";

  src = pkgs.fetchzip {
    url = "https://www.dcmembers.com/jibsen/download/61/?wpdmdl=61";
    hash = "sha256-JK+vnOyhAbwT825S+WKbQuWgRrfZZHfyhaMQ/6ljO8s=";
    extension = "zip";
    stripRoot = false;
  };

  buildInputs = with pkgs; [
    bdf2psf
    fontforge
  ];

  buildPhase = ''
    # Get the base Dina font
    cp BDF/Dina_r400-9.bdf ./dina.bdf

    # Set the AVERAGE_WIDTH property on the font
    sed 's/STARTPROPERTIES 16/STARTPROPERTIES 17\
    AVERAGE_WIDTH 70/' ./dina.bdf > ./dina-mod.bdf

    # Reencode the font from code page CP1252 (Windows) to unicode
    fontforge -lang=ff -c "Open(\"dina-mod.bdf\"); Reencode(\"win\", 1); Reencode(\"iso10646-1\"); Generate(\"dina-enc.bdf\")"
    mv dina-enc-*.bdf dina-enc.bdf

    # Move the artsy characters around
    sed -i 's/STARTCHAR uni000E$/STARTCHAR uni2518/' ./dina-enc.bdf
    sed -i 's/ENCODING 14$/ENCODING 9496/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni000F$/STARTCHAR uni2514/' ./dina-enc.bdf
    sed -i 's/ENCODING 15$/ENCODING 9492/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0010$/STARTCHAR uni250C/' ./dina-enc.bdf
    sed -i 's/ENCODING 16$/ENCODING 9484/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0011$/STARTCHAR uni2510/' ./dina-enc.bdf
    sed -i 's/ENCODING 17$/ENCODING 9488/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0012$/STARTCHAR uni2500/' ./dina-enc.bdf
    sed -i 's/ENCODING 18$/ENCODING 9472/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0013$/STARTCHAR uni2502/' ./dina-enc.bdf
    sed -i 's/ENCODING 19$/ENCODING 9474/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0014$/STARTCHAR uni2524/' ./dina-enc.bdf
    sed -i 's/ENCODING 20$/ENCODING 9508/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0015$/STARTCHAR uni2534/' ./dina-enc.bdf
    sed -i 's/ENCODING 21$/ENCODING 9524/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0016$/STARTCHAR uni251C/' ./dina-enc.bdf
    sed -i 's/ENCODING 22$/ENCODING 9500/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0017$/STARTCHAR uni252C/' ./dina-enc.bdf
    sed -i 's/ENCODING 23$/ENCODING 9516/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0018$/STARTCHAR uni253C/' ./dina-enc.bdf
    sed -i 's/ENCODING 24$/ENCODING 9532/' ./dina-enc.bdf
    sed -i 's/STARTCHAR uni0019$/STARTCHAR uni2592/' ./dina-enc.bdf
    sed -i 's/ENCODING 25$/ENCODING 9618/' ./dina-enc.bdf

    # Create the equivalents file
    touch empty.equivalents

    # Convert the bdf to psf
    bdf2psf --fb ./dina-enc.bdf \
      ./empty.equivalents \
      ${pkgs.bdf2psf}/share/bdf2psf/fontsets/Uni2.512 \
      512 ./dina.psfu ./dina.sfm
  '';

  installPhase = ''
    install -Dm644 -t $out/debug ./*.*
    install -Dm644 -t $out/debug/BDF ./BDF/*.*
    install -Dm644 -t $out/share/consolefonts dina.psfu
  '';
}
