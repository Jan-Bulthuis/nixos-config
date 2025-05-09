{ pkgs, ... }:

{
  name = "Adwaita Mono";
  package = pkgs.adwaita-fonts;
  recommendedSize = 12;
  fallbackFonts = [ ];
}
