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
  options.modules.rust = {
    enable = mkEnableOption "rust";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [
      # rustup
      rustc
      cargo
      gcc
      # lldb
      gdb
      rust-analyzer
      rustfmt
    ];

    # VSCode configuration
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
        # ms-vscode.cpp-tools
        vadimcn.vscode-lldb
      ];

      userSettings = {
        "[rust]" = {
          "editor.inlayHints.enabled" = "off";
        };
      };
    };

    # Neovim configuration
    programs.nixvim = {
      plugins.rust-tools = {
        enable = true;
      };
    };
  };
}
