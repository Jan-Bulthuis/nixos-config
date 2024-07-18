{ pkgs, ... }:

{
  name = "Dina";
  package = pkgs.dina-font;
  recommendedSize = 9;
  fallbackFonts = [
    "Cozette"
  ];
}