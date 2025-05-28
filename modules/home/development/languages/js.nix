{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.js;
in
{
  options.modules.js = {
    enable = mkEnableOption "js";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [
      nodejs
      tailwindcss
    ];

    # VSCode configuration
    programs.vscode = {
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          bradlc.vscode-tailwindcss
        ];

        userSettings = { };
      };
    };

    # Neovim configuration
    # programs.nixvim = { };
  };
}
