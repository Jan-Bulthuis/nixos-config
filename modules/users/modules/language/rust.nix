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
      rustup
      # rustc
      # cargo
      gcc
      lldb
      # rust-analyzer
      # rustfmt
      # clippy
    ];

    # VSCode configuration
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb
        tamasfe.even-better-toml
        serayuzgur.crates
      ];

      userSettings = {
        "[rust]" = {
          "editor.inlayHints.enabled" = "off";
        };
        "rust-analyzer.check.command" = "clippy";
        "rust-analyzer.showUnlinkedFileNotification" = false;
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
