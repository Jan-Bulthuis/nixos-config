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
      rev = "e680b367c726e2ae37d541328fe81f8daaf49a6c";
      sha256 = "sha256-fYEf0IgsNJp/hcb+C3FKtJvVabPDQs64hdL0izNBwXc=";
    }
  );

  # Stylix
  stylix = import (
    pkgs.fetchFromGitHub {
      owner = "danth";
      repo = "stylix";
      rev = "5f912cecb4e1c5c794316c4b79b9b5d57d43e100";
      sha256 = "sha256-SX1R/WlHEIf9BPT4YBnlVyXRyWNlzYMtKpwXnT9+DPM=";
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
    # <home-manager/nixos>

    # Import system wide configuration required for user modules
    ../../user-modules/systemwide/default.nix
  ];

  options = {
    machine.sudo-groups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Groups assigned to sudo users.";
    };
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
      ../../user-modules/default.nix

      # Custom packages
      ../../pkgs/default.nix
    ];

    # Create users
    users.users = attrsets.concatMapAttrs (name: value: {
      ${name} = {
        isNormalUser = true;
        extraGroups = mkIf value.sudo (
          [
            "wheel"
          ]
          ++ config.machine.sudo-groups
        );
      };
    }) config.machine.users;

    # Create home manager configuration for users
    home-manager.users = attrsets.concatMapAttrs (name: value: {
      ${name} = value.configuration;
    }) config.machine.users;
  };
}
