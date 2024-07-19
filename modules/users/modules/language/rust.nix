{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.rust;
in {
  options.modules.rust = {
    enable = mkEnableOption "rust";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [
        rustc
        cargo
        rust-analyzer
        rustfmt
    ];

    # VSCode configuration
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
      ];

      userSettings = {
        "[rust]" = {
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