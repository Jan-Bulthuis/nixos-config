{
  ...
}:

{
  nixpkgs.config = {
    # android_sdk.accept_license = true; # TODO: Move to android module
    packageOverrides = pkgs: {
      dina-vector = pkgs.callPackage ./fonts/dina-vector.nix { };
      wqy-zenhei = pkgs.callPackage ./fonts/wqy-zenhei.nix { };
      wqy-microhei = pkgs.callPackage ./fonts/wqy-microhei.nix { };
      wqy-bitmapsong = pkgs.callPackage ./fonts/wqy-bitmapsong.nix { };
      temp-quickgui = pkgs.callPackage ./temp/quickgui.nix { };
      # qutebrowser = pkgs.callPackage ./fixes/qutebrowser/default.nix { };
      jellyfin-tui = pkgs.callPackage ./custom/jellyfin-tui.nix { };
    };
  };
}
