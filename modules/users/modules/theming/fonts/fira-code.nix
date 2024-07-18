{ pkgs, ... }:

{
  name = "Fira Code";
  package = pkgs.fira-code;
  recommendedSize = 12;
  fallbackFonts = [];
}