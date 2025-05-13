{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.bash;
in
{
  options.modules.bash = {
    enable = mkEnableOption "bash";
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        "..." = "cd ../..";
      };
      description = "Shell aliases";
    };
  };

  config.programs.bash = {
    enable = cfg.enable;
    shellAliases = cfg.aliases;
  };
}
