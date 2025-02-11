{
  ...
}:

let
  overlay = final: prev: {
    dina-vector = prev.callPackage ./fonts/dina-vector.nix { };
    dina-psf = prev.callPackage ./fonts/dina-psf.nix { };
    ttf2psf = prev.callPackage ./fonts/ttf2psf.nix { };
    wqy-zenhei = prev.callPackage ./fonts/wqy-zenhei.nix { };
    wqy-microhei = prev.callPackage ./fonts/wqy-microhei.nix { };
    wqy-bitmapsong = prev.callPackage ./fonts/wqy-bitmapsong.nix { };
  };
in
{
  nixpkgs.overlays = [ overlay ];
}
