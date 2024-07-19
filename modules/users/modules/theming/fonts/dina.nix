{ pkgs, ... }:

{
  name = "Dina";
  package = pkgs.dina-font;
  recommendedSize = 9;
  fallbackFonts = [
    "Cozette"
    "wenquanyi bitmap song"
    "Symbols Nerd Font Mono"
  ];
}
