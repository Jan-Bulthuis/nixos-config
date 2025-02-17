{ pkgs, ... }:

{
  name = "WenQuanYi Zen Hei";
  package = pkgs.wqy-zenhei;
  recommendedSize = 12;
  fallbackFonts = [ ];
}
