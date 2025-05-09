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
  options.modules.ryujinx = {
    enable = mkEnableOption "ryujinx";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ryubing
    ];

    # TODO: Make more general
    wayland.windowManager.river.settings.rule-add."-app-id"."'Ryujinx'" = "fullscreen";
  };
}
