{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.nixgreety;
in
{
  options.modules.nixgreety = {
    enable = mkEnableOption "nixgreety";
  };

  config = mkIf cfg.enable {
    # Enable greetd
    modules.greetd = {
      enable = true;
      command = "${pkgs.nixgreety}/bin/nixgreety";
    };

    services.greetd.settings.default_session.user = "root";

    environment.systemPackages = with pkgs; [
      nixgreety
    ];
  };
}
