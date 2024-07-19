{ pkgs, ... }:

{
  name = "Symbols Nerd Font Mono";
  package = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
  recommendedSize = 12;
  fallbackFonts = [ ];
}
