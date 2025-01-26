{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.modrinth;
in
{
  options.modules.modrinth = {
    enable = mkEnableOption "modrinth";
  };

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [
      "modrinth-app"
      "modrinth-app-unwrapped"
    ];

    home.packages = with pkgs; [
      modrinth-app
    ];
  };
}
