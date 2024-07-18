{ lib, config, pkgs, ... }:

{
  imports = [
    ./greetd/default.nix
    ./tuigreet/default.nix
    ./users/default.nix
  ];
}