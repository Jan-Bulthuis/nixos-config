{ input, pkgs, config, ... }:

{
  # Set the state version
  home.stateVersion = "24.05";
  
  imports = [
    ./tools/zathura/default.nix
  ];
}