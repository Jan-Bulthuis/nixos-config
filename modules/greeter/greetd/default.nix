{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.greetd;
in
{
  options.modules.greetd = {
    enable = mkEnableOption "greetd";
    command = mkOption {
      type = types.str;
      default = "";
      description = "Command to run to show greeter.";
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = cfg.command;
        user = mkDefault "greeter";
      };
    };
  };
}
