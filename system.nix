{ config, lib, pkgs, ... }:

{
  options = {
    custom.laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether the current system is a laptop.";
    };
  };
}