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
    # TODO: Make sure everything works even without a default value here
    # Maybe make sure most gui applications do not exist in the default specialisation
    default = "foot";
    description = "Default terminal application";
  };
}
