{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  # Desktop configuration module
  desktopConfigurationModule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Desktop environment name.";
      };
      type = mkOption {
        type = types.enum [
          "custom"
          "gnome"
        ];
        description = "Desktop environment type.";
      };
      config = mkOption {
        type = types.attrs;
        default = { };
        description = "Desktop environment configuration";
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = { };
        description = "Extra configuration for the configured desktop environment";
      };
    };
  };

  customBuilder = config: {
    configuration = recursiveUpdate { desktop.name = config.name; } config.extraConfig;
  };

  # Environment builders
  environmentBuilders = {
    custom = customBuilder;
  };

  cfg = config.desktop;
in
{
  imports = [
    ./custom/default.nix
    ./theming/default.nix
  ];

  options.desktop = {
    name = mkOption {
      type = types.str;
      default = "Shell";
      description = "Desktop configuration name.";
    };
    initScript = mkOption {
      type = types.lines;
      default = ''
        ${pkgs.ncurses}/bin/clear
        ${pkgs.bashInteractive}/bin/bash
      '';
      description = "Bash script to execute after logging in.";
    };
    session = {
      type = mkOption {
        type = types.enum [
          "wayland"
          "x11"
          "tty"
        ];
        default = "tty";
        description = "Session type.";
      };
      desktop = mkOption {
        type = types.str;
        default = "tty";
        description = "Desktop environment name.";
      };
    };
    environments = mkOption {
      type = types.attrsOf desktopConfigurationModule;
      default = { };
      description = "Desktop environments. Every environment will be built as a specialization.";
    };
  };

  config = {
    specialisation = mapAttrs (
      name: value: (environmentBuilders."${value.type}" value)
    ) cfg.environments;

    # Create session files
    home.extraBuilderCommands = ''
      mkdir $out/session
      echo "${cfg.name}" > $out/session/name
      ln -s ${
        pkgs.writeTextFile {
          name = "desktop-init";
          text =
            ''
              #!${pkgs.bash}/bin/bash

            ''
            + cfg.initScript;
          executable = true;
        }
      } $out/session/init
      ln -s ${
        pkgs.writeTextFile {
          name = "session-env";
          text = ''
            XDG_SESSION_TYPE=${cfg.session.type}
            XDG_CURRENT_DESKTOP=${cfg.session.desktop}
            XDG_SESSION_DESKTOP=${cfg.session.desktop}
          '';
        }
      } $out/session/env
    '';
  };
}
