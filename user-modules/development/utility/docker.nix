{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.docker;
in
{
  options.modules.docker = {
    enable = mkEnableOption "docker";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [
      docker
      docker-compose
    ];

    # Allow unfree
    modules.unfree.allowedPackages = [
    ];

    # VSCode configuration
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        ms-azuretools.vscode-docker
      ];

      userSettings = {
      };
    };

    # Neovim configuration
    programs.nixvim = { };
  };
}
