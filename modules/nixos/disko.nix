{
  lib,
  config,
  inputs,
  ...
}:

with lib;
let
  cfg = config.modules.disko;
  profile = import "${inputs.self}/profiles/disko/${cfg.profile}.nix";
in
{
  options.modules.disko = {
    enable = mkEnableOption "Disko module";
    profile = mkOption {
      type = types.str;
      default = null;
      description = "The profile to use for the disko module.";
    };
  };

  config = mkIf cfg.enable { disko.devices = profile.disko.devices; };
}
