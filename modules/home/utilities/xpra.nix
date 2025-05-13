{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.xpra;
in
{
  options.modules.xpra = {
    enable = mkEnableOption "Enable xpra";
    hosts = mkOption {
      type = types.listOf types.str;
      default = { };
      description = "xpra hosts";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xpra
    ];

    xdg.desktopEntries = (
      listToAttrs (
        map
          (entry: {
            name = "xpra${
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
              host:
              let
                uri = "tcp://${host}:15151/7";
              in
              [
                {
                  name = "Xpra - Attach";
                  comment = host;
                  exec = "xpra attach --min-quality=100 --min-speed=100 --encoding=png --speaker=off ${uri}";
                }
                {
                  name = "Xpra - Detach";
                  comment = host;
                  exec = "xpra detach ${uri}";
                }
              ]
            ) cfg.hosts
          )
      )
    );
  };
}
