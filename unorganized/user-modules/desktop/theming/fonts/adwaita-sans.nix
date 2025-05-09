{ pkgs, ... }:

{
  name = "Adwaita Sans";
  package = pkgs.adwaita-fonts;
  recommendedSize = 12;
  fallbackFonts = [ ];
}
