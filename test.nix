{ config, lib, pkgs, ... }:

{
  config = {
    custom.users.jan = {
      enable = true;
      sudo = true;
      configuration = ./users/jan.nix;
    };
  };
}