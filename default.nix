{ config, lib, pkgs, ... }:

{
  imports = [
    # TODO: Temporary until it has been subdivided into modules.
    ./merged.nix

    # Modules
    ./modules/default.nix

    # System configuration options
    ./system.nix

    # Import test configuration
    ./test.nix
  ];

  config = {
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable default modules
    modules = {
      # Greeter
      tuigreet.enable = true; 
    };

    # Localization settings
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";
  };
}