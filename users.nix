{ config, lib, pkgs, ... }:

let
  userModule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether the user is enabled.";
      };
      sudo = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether the user is allowed sudo access.";
      };
      configuration = lib.mkOption {
        type = lib.types.path;
        default = ./users/base.nix;
        description = "What home manager configuration to use for this user.";
      };
    };
  };
in {
  options = {
    custom.users = lib.mkOption {
      type = lib.types.attrsOf userModule;
      default = {};
      description = "Users configured on this system.";
    };
  };

  config = {
    users.users = lib.attrsets.concatMapAttrs (name: value: {
      ${name} = {
        isNormalUser = true;
        extraGroups = lib.mkIf value.sudo [ "wheel" ];
      };
    }) config.custom.users;

    home-manager.users = lib.attrsets.concatMapAttrs (name: value: {
      ${name} = value.configuration;
    }) config.custom.users;
  };
}