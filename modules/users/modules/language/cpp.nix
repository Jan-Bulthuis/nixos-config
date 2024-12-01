{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.rust;
in
{
  options.modules.cpp = {
    enable = mkEnableOption "cpp";
  };

  config = mkIf cfg.enable {
    # Allow unfree
    modules.unfree.allowedPackages = [
      "vscode-extension-ms-vscode-cpptools"
      # TODO: Remove, it should not be here
      "android-studio-stable"
      "android-sdk-cmdline-tools"
      "android-sdk-tools"
    ];

    # Gitignore additions
    modules.git.ignores = [
      ".ccls-cache"
    ];

    # Development packages
    home.packages = with pkgs; [
      gnumake
    ];

    # VSCode configuration
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        ms-vscode.cpptools
        ms-vscode.cmake-tools
      ];

      userSettings = {
        # "C_Cpp.clang_format_fallbackStyle" = "{ BasedOnStyle: Google, IndentWidth: 4 }";
      };
    };

    # Neovim configuration
    programs.nixvim = {
      plugins.lsp.servers.ccls.enable = true;
    };
  };
}
