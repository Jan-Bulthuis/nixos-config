{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.jupyter;
in
{
  options.modules.jupyter = {
    enable = mkEnableOption "jupyter";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [ ];

    modules.python.extraPythonPackages = p: [
      p.jupyter
      p.notebook
    ];

    # VSCode configuration
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        ms-toolsai.jupyter
        ms-toolsai.jupyter-renderers
      ];

      userSettings = { };
    };

    # Neovim configuration
    programs.nixvim = { };
  };
}
