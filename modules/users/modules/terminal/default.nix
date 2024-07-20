{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
{
  options.default.terminal = mkOption {
    type = types.str;
    description = "Default terminal application";
  };
}
