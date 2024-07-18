{ pkgs, ... }:

{
  name = "WenQuanYi Micro Hei";
  package = pkgs.wqy-microhei;
  recommendedSize = 12;
  fallbackFonts = [];
}