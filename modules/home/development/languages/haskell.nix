{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.haskell;
in
{
  options.modules.haskell = {
    enable = mkEnableOption "haskell";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [
      haskell.compiler.ghc948
      (haskell-language-server.override { supportedGhcVersions = [ "948" ]; })
    ];

    # VSCode configuration
    programs.vscode = {
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          haskell.haskell
          justusadam.language-haskell
        ];

        userSettings = {
          "[haskell]" = { };
          # "haskell.formattingProvider" = "fourmolu";
        };
      };
    };

    # Neovim configuration
    # programs.nixvim = { };
  };
}
