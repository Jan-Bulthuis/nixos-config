{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.glpaper;
in
{
  options.modules.glpaper = {
    enable = mkEnableOption "glpaper";
    shader = mkOption {
      type = types.path;
      default = ./shaders/waves.glsl;
      description = "Shader to use for the background";
    };
  };

  config = mkIf cfg.enable { home.packages = [ pkgs.glpaper ]; };
}
