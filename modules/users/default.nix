{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
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
    # Import system wide configuration required for user modules
    ../../user-modules/systemwide/default.nix

    # Import systemwide configuration
    ./systemwide.nix
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
