{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.zathura;
  colors = config.desktop.theming.colors;
in
{
  options.modules.zathura.enable = lib.mkEnableOption "zathura";

  config = lib.mkIf cfg.enable {
    programs.zathura = {
      enable = true;

      options = {
        guioptions = "none";
        recolor = true;
        recolor-keephue = false;
        recolor-darkcolor = lib.mkForce "#${colors.accent}";
        recolor-lightcolor = lib.mkForce "#${colors.bg}";
      };
    };

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = "zathura";
      };
    };
  };
}
