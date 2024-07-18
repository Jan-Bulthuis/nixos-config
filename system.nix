{ config, lib, pkgs, ... }:

{
  options = {
    machine.laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether the current system is a laptop.";
    };
  };
}