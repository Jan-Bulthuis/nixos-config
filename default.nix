{ config, lib, pkgs, ... }:

{
  imports = [
    # Temporary until it has been subdivided into modules.
    ./merged.nix

    # Automation for user configuration
    ./users.nix

    # System configuration options
    ./system.nix

    # Import test configuration
    ./test.nix
  ];

  options = {
    custom.laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether the current system is a laptop.";
    };
  };

  config = {
    # Set the state version
    system.stateVersion = "24.05"
  };
}