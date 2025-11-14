{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.profiles.gnome;
in
{
  options.modules.profiles.gnome = {
    enable = mkEnableOption "Graphical GNOME environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # firefox # TODO: Move to dediated module
    ];

    modules = {
      profiles.base.enable = true;

      # Desktop environment
      desktop.gnome.enable = true;
      # desktop.tiling.enable = true;

      # Browser
      # firefox = {
      #   enable = true;
      #   default = false;
      # };
      # qutebrowser = {
      #   enable = true;
      #   default = true;
      # };

      # Tools
      # obsidian.enable = true;
      # zathura.enable = true;

      # Development
      # neovim.enable = true;
      vscode.enable = true;
    };
  };
}
