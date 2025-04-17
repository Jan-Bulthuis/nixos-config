{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.wprs;

  wprsHostConfigurationModule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Command name.";
      };
      command = mkOption {
        type = types.str;
        description = "Command to run.";
      };
    };
  };
in
{
  options.modules.wprs = {
    enable = mkEnableOption "Enable wprs";
    hosts = mkOption {
      type = types.attrsOf (types.listOf wprsHostConfigurationModule);
      default = { };
      description = "wprs commands to add as desktop files";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wprs
    ];

    xdg.desktopEntries = (
      listToAttrs (
        map
          (entry: {
            name = "wprs${
              builtins.substring 0 12 (builtins.hashString "sha256" "${entry.name} (${entry.comment})")
            }";
            value = entry // {
              type = "Application";
              terminal = false;
              genericName = entry.comment;
            };
          })
          (
            concatMap (
              entry:
              let
                host = entry.name;
                commands = entry.value;
                hostEntries = [
                  {
                    name = "Attach";
                    comment = host;
                    exec = "wprs --pulseaudio-forwarding False ${host} attach";
                  }
                  {
                    name = "Detach";
                    comment = host;
                    exec = "wprs ${host} detach";
                  }
                ];
                commandEntries = map (command: {
                  name = "${command.name}";
                  comment = host;
                  exec = "wprs --pulseaudio-forwarding False ${host} run \"${command.command}\"";
                }) commands;
              in
              (hostEntries ++ commandEntries)
            ) (attrsToList cfg.hosts)
          )
      )
    );
  };
}
