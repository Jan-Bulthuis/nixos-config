{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.nix;
in
{
  options.modules.nix = {
    enable = mkEnableOption "nix";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [
      nix-tree
      nixfmt-rfc-style
      nixd
    ];

    # Add nix tree
    xdg.desktopEntries.nix-tree = {
      exec = "${pkgs.nix-tree}/bin/nix-tree";
      name = "Nix Tree";
      terminal = true;
      type = "Application";
    };

    # VSCode configuration
    programs.vscode = {
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [ jnoortheen.nix-ide ];

        userSettings = {
          "[nix]" = {
            "editor.tabSize" = 2;
          };
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
          "nix.serverSettings" = {
            nixd = {
              formatting = {
                command = [ "nixfmt" ];
              };
            };
          };
        };
      };
    };

    # Neovim configuration
    programs.nixvim = {

    };
  };
}
