{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.vscode;
  theme = config.desktop.theming;
in
{
  options.modules.vscode = {
    enable = mkEnableOption "vscode";
    codeFont = mkOption {
      type = types.anything;
      default = theme.fonts.pkgs."Fira Code";
    };
    fallbackFont = mkOption {
      type = types.anything;
      default = theme.fonts.pkgs."Symbols Nerd Font Mono";
    };
  };

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [
      "vscode"
      "vscode-extension-github-copilot"
      "vscode-extension-github-copilot-chat"
      "vscode-extension-ms-vsliveshare-vsliveshare"
    ];

    desktop.theming.fonts.extraFonts = [ cfg.codeFont ];

    programs.vscode = {
      enable = true;

      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions; [
        eamodio.gitlens
        ms-vscode.hexeditor
        mkhl.direnv
        usernamehw.errorlens
        gruntfuggly.todo-tree
        github.copilot
        github.copilot-chat
        tomoki1207.pdf
        ms-vsliveshare.vsliveshare
      ];

      userSettings =
        let
          font-family = mkForce "'${cfg.codeFont.name}', '${cfg.fallbackFont.name}'";
          # TODO: Move the conversion factor to theme settings
          font-size = mkForce cfg.codeFont.recommendedSize; # Convert pt to px
        in
        {
          # Font setup
          "editor.fontFamily" = font-family;
          "editor.inlayHints.fontFamily" = font-family;
          "editor.inlineSuggest.fontFamily" = font-family;
          "editor.fontSize" = font-size;
          "editor.fontLigatures" = true;
          "terminal.integrated.fontFamily" = font-family;
          "terminal.integrated.fontSize" = font-size;
          "chat.editor.fontFamily" = font-family; # TODO: Change this font to the standard UI font
          "chat.editor.fontSize" = font-size;
          "debug.console.fontFamily" = font-family;
          "debug.console.fontSize" = font-size;
          "scm.inputFontFamily" = font-family; # TODO: Change this font to the standard UI font
          "scm.inputFontSize" = font-size;
          "markdown.preview.fontFamily" = mkForce theme.fonts.sansSerif.name; # TODO: Change this font to the standard UI font
          "markdown.preview.fontSize" = mkForce theme.fonts.sansSerif.recommendedSize;

          # Formatting
          "editor.formatOnSave" = true;
          "editor.tabSize" = 4;

          # Layout
          "window.menuBarVisibility" = "hidden";

          # Git settings
          "git.autofetch" = true;
          "git.enableSmartCommit" = false;
          "git.suggestSmartCommit" = false;

          # Disable update notifications
          "update.mode" = "none";

          # TODO: Move to direnv module
          # Ignore direnv folder
          "files.exclude" = {
            ".direnv" = true;
          };
        };
    };
  };
}
