{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.go;
in
{
  options.modules.go = {
    enable = mkEnableOption "go";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [
    ];

    # VSCode configuration
    programs.vscode = {
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          golang.go

        ];

        userSettings = {
        };
      };
    };

    # Neovim configuration
    # programs.nixvim = {
    #   plugins.rustaceanvim = {
    #     enable = true;
    #   };
    # };
  };
}
