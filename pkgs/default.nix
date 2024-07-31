{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
{
  nixpkgs.config.packageOverrides = pkgs: rec {
    wqy-zenhei = pkgs.callPackage ./fonts/wqy-zenhei.nix { };
    wqy-microhei = pkgs.callPackage ./fonts/wqy-microhei.nix { };
    wqy-bitmapsong = pkgs.callPackage ./fonts/wqy-bitmapsong.nix { };
  };
}
