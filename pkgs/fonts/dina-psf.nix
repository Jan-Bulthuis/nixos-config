{
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation {
  pname = "dina-psfu";
  version = "1.0.0";

  unpackPhase = ''
    true
  '';

  buildInputs = with pkgs; [
    bdf2psf
    fontforge
    kbd
  ];

  buildPhase = ''
    # Get the base Dina font
    cp ${pkgs.dina-font.bdf}/share/fonts/misc/Dina_r400-9.bdf ./dina.bdf

    # Set the AVERAGE_WIDTH property on the font
    sed 's/STARTPROPERTIES 16/STARTPROPERTIES 17\
    AVERAGE_WIDTH 70/' ./dina.bdf > ./dina-enc.bdf

    # # Reencode the font from code page CP1252 (Windows) to unicode
    # fontforge -lang=ff -c "Open(\"dina-mod.bdf\"); Reencode(\"win\", 1); Reencode(\"iso10646-1\"); Generate(\"dina-enc.bdf\")"
    # mv dina-enc-*.bdf dina-enc.bdf

    # Convert the bdf to psf
    bdf2psf --fb ./dina-enc.bdf \
      ${pkgs.bdf2psf}/share/bdf2psf/standard.equivalents \
      ${pkgs.bdf2psf}/share/bdf2psf/fontsets/Uni3.512 \
      512 ./dina-enc.psfu ./dina.sfm

    # Get the font table
    psfgettable ./dina-enc.psfu ./dina.table

    # Add some entries to the font table
    echo "0x0e U+2518" >> ./dina.table
    echo "0x0f U+2514" >> ./dina.table
    echo "0x10 U+250c" >> ./dina.table
    echo "0x11 U+2510" >> ./dina.table
    echo "0x12 U+2500" >> ./dina.table
    echo "0x13 U+2502" >> ./dina.table
    echo "0x14 U+2524" >> ./dina.table
    echo "0x15 U+2534" >> ./dina.table
    echo "0x16 U+251c" >> ./dina.table
    echo "0x17 U+252c" >> ./dina.table
    echo "0x18 U+253c" >> ./dina.table
    echo "0x19 U+2592" >> ./dina.table

    # Rebuild the font
    psfstriptable ./dina-enc.psfu ./dina-stripped.psfu
    psfaddtable ./dina-stripped.psfu ./dina.table ./dina.psfu

    # For debugging, get the table again
    psfgettable ./dina.psfu ./dina-final.table
  '';

  installPhase = ''
    install -Dm644 -t $out/debug *
    install -Dm644 -t $out/share/consolefonts dina.psfu
  '';
}
