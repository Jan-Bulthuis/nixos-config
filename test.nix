{ config, lib, pkgs, ... }:

{
  config = {
    system.stateVersion = "24.05";

    machine.users.jan = {
      sudo = true;
      configuration = ./users/jan.nix;
    };

    machine.users.second = {
      sudo = false;
      configuration = ./users/jan.nix;
    };
  };
}