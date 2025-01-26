{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.ryujinx;
in
{
  options.modules.modrinth = {
    enable = mkEnableOption "ryujinx";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ryujinx
    ];
  };
}
