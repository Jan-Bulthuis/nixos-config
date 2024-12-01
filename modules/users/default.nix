{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  # Nixvim
  nixvim = import (
    # builtins.fetchGit {
    #   url = "https://github.com/nix-community/nixvim";
    #   # ref = "nixos-24.05";
    # }
    pkgs.fetchFromGitHub {
      owner = "nix-community";
      repo = "nixvim";
      rev = "master";
      sha256 = "sha256-xPf3jjDBDA9oMVnWU5DJ8gINCq2EPiupvF/4rD/0eEI=";
    }
  );

  # Stylix
  stylix = import (
    pkgs.fetchFromGitHub {
      owner = "danth";
      repo = "stylix";
      rev = "master";
      sha256 = "sha256-8uTKUHkaU980J5kRnLYrdwmjZYB88eBGUk1oVgIUHFE=";
    }
  );

  # User configuration
  userModule = types.submodule {
    options = {
      sudo = mkOption {
        type = types.bool;
        default = false;
        example = true;
        description = "Whether the user is allowed sudo access.";
      };
      configuration = mkOption {
        type = types.path;
        default = ./users/base.nix;
        description = "What home manager configuration to use for this user.";
      };
      desktopInit = mkOption {
        type = types.lines;
        default = "";
        description = "Bash script to execute after initial log in.";
      };
    };
  };
in
{
  imports = [
    # Import home manager
    <home-manager/nixos>

    # Import system wide configuration required for user modules
    ./modules/systemwide/default.nix
  ];

  options = {
    machine.users = mkOption {
      type = types.attrsOf userModule;
      default = { };
      description = "Users configured on this system.";
    };
  };

  config = {
    # Add required home manager modules
    home-manager.sharedModules = [
      # Stylix for theming
      stylix.homeManagerModules.stylix

      # Nixvim for neovim
      nixvim.homeManagerModules.nixvim

      # Modules
      ./modules/default.nix

      # Custom packages
      ../../pkgs/default.nix
    ];

    # Create users
    users.users = attrsets.concatMapAttrs (name: value: {
      ${name} = {
        isNormalUser = true;
        extraGroups = mkIf value.sudo [
          "wheel"
          "docker"
        ];
      };
    }) config.machine.users;

    # Create home manager configuration for users
    home-manager.users = attrsets.concatMapAttrs (name: value: {
      ${name} = value.configuration;
    }) config.machine.users;
  };
}
