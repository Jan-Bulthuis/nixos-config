{
  ...
}:

let
  overlay = final: prev: {
    dina-psfu = prev.callPackage ./fonts/dina-psfu.nix { };
    ttf2psf = prev.callPackage ./fonts/ttf2psf.nix { };
    wqy-zenhei = prev.callPackage ./fonts/wqy-zenhei.nix { };
    wqy-microhei = prev.callPackage ./fonts/wqy-microhei.nix { };
    wqy-bitmapsong = prev.callPackage ./fonts/wqy-bitmapsong.nix { };

    # ly = prev.callPackage ./programs/ly/default.nix { };
  };
in
{
  nixpkgs.overlays = [ overlay ];
}
