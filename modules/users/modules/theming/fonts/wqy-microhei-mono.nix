{ pkgs, ... }:

{
  name = "WenQuanYi Micro Hei Mono";
  package = pkgs.wqy-microhei;
  recommendedSize = 12;
  fallbackFonts = [];
}