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
    dina-font.bdf
    bdf2psf
  ];

  buildPhase = ''
    cp ${pkgs.dina-font.bdf}/share/fonts/misc/Dina_r400-9.bdf ./dina.bdf

    # Set the AVERAGE_WIDTH property on the font
    sed 's/STARTPROPERTIES 16/STARTPROPERTIES 17\
    AVERAGE_WIDTH 70/' ./dina.bdf > ./dina-mod.bdf

    # Convert the bdf to psf
    bdf2psf --fb ./dina-mod.bdf \
      ${pkgs.bdf2psf}/share/bdf2psf/standard.equivalents \
      ${pkgs.bdf2psf}/share/bdf2psf/ascii.set+${pkgs.bdf2psf}/share/bdf2psf/linux.set+${pkgs.bdf2psf}/share/bdf2psf/useful.set \
      512 ./dina.psf
  '';

  installPhase = ''
    install -Dm644 -t $out/share/consolefonts *.psf
  '';
}
