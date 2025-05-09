{
  lib,
  ...
}:

with lib;
{
  options.modules.shell = {
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        "..." = "cd ../..";
      };
      description = "Shell aliases";
    };
  };
}
