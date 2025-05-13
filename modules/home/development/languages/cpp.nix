{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.cpp;
in
{
  options.modules.cpp = {
    enable = mkEnableOption "cpp";
  };

  config = mkIf cfg.enable {
    # Gitignore additions
    modules.git.ignores = [
      ".ccls-cache"
    ];

    # Development packages
    home.packages = with pkgs; [
      gnumake
      gcc
    ];

    # VSCode configuration
    programs.vscode = {
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          ms-vscode.cpptools
          ms-vscode.cmake-tools
          ms-vscode.cpptools-extension-pack
        ];

        userSettings = {
          # TODO: Add setting to set the compiler, it currently needs to be set for each workspace individually
          # "C_Cpp.clang_format_fallbackStyle" = "{ BasedOnStyle: Google, IndentWidth: 4 }";
        };
      };
    };

    # Neovim configuration
    # programs.nixvim = {
    #   plugins.lsp.servers.ccls.enable = true;
    # };
  };
}
