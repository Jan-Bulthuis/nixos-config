{
  ...
}:

{
  nixpkgs.config = {
    packageOverrides = pkgs: {
      dina-vector = pkgs.callPackage ./fonts/dina-vector.nix { };
      wqy-zenhei = pkgs.callPackage ./fonts/wqy-zenhei.nix { };
      wqy-microhei = pkgs.callPackage ./fonts/wqy-microhei.nix { };
      wqy-bitmapsong = pkgs.callPackage ./fonts/wqy-bitmapsong.nix { };
    };
  };
}
