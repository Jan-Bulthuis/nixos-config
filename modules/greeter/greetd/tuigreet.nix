{config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.tuigreet;
in {
  options.modules.tuigreet = { 
    enable = mkEnableOption "tuigreet"; 
    greeting = mkOption {
      type = types.str;
      default = "Hewwo! >_< :3";
      description = "Greeting message to show.";
    }; 
    command = mkOption {
      type = types.str;
      default = "~/.initrc";
      description = "Command to run after logging in.";
    };
  };

  config = mkIf cfg.enable {
    # Enable greetd
    modules.greetd = {
      enable = true;
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --greeting \"${cfg.greeting}\" --time --cmd \"${cfg.command}\" --asterisks";
    };

    # Enable silent boot to prevent late log messages from messing up tuigreet
    modules.silent-boot.enable = true;
  };
}