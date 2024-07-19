{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
# let
#   mkPackage = path: (mkOption {
#     type = types.package;
#     default = (pkgs.callPackage path) {};
#     description = (mkPackage path).default.name;
#   });
# in {
#   options.pkgs = {
#     # Add all custom packages
#     wqy-zenhei = mkPackage ./fonts/wqy-zenhei.nix;
#     wqy-microhei = mkPackage ./fonts/wqy-microhei.nix;
#     wqy-bitmapsong = mkPackage ./fonts/wqy-bitmapsong.nix;
#   }; 
# }
{
  nixpkgs.config.packageOverrides = pkgs: rec {
    wqy-zenhei = pkgs.callPackage ./fonts/wqy-zenhei.nix { };
    wqy-microhei = pkgs.callPackage ./fonts/wqy-microhei.nix { };
    wqy-bitmapsong = pkgs.callPackage ./fonts/wqy-bitmapsong.nix { };
  };
}
