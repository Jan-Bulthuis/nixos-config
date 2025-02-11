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
    dina-font
    # ttf2psf
    bdf2psf
    # kbd
  ];

  # buildPhase = ''
  #   # Get the base Dina otb font
  #   cp ${pkgs.dina-font}/share/fonts/misc/DinaMedium9.otb ./dina.otb

  #   # Create the character set
  #   cp ${pkgs.ttf2psf}/share/ttf2psf/ascii

  #   # Convert to psfu
  #   ttf2psu -g -c ${pkgs.ttf2psf}/share/ttf2psf/ -e ${pkgs.ttf2psf}/share/ttf2psf/standard.equivalents dina.otb dina.psfu.gz
  # '';

  buildPhase = ''
    # Get the base Dina font
    cp ${pkgs.dina-font.bdf}/share/fonts/misc/Dina_r400-10.bdf ./dina.bdf

    # Set the AVERAGE_WIDTH property on the font
    sed 's/STARTPROPERTIES 16/STARTPROPERTIES 17\
    AVERAGE_WIDTH 80/' ./dina.bdf > ./dina-mod.bdf

    # Convert the bdf to psf
    bdf2psf --fb ./dina-mod.bdf \
      ${pkgs.bdf2psf}/share/bdf2psf/standard.equivalents \
      ${pkgs.bdf2psf}/share/bdf2psf/fontsets/Uni2.512 \
      512 ./dina.psf
  '';

  installPhase = ''
    install -Dm644 -t $out/share/consolefonts dina.psf
  '';
}
