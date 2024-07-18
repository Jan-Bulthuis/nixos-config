{ pkgs, ... }:

{
  name = "wenquanyi bitmap song";
  package = pkgs.wqy-bitmapsong;
  recommendedSize = 12;
  fallbackFonts = [];
}