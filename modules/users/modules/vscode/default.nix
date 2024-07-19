{config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.vscode;
  theme = config.theming;
in {
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
    modules.unfree.allowedPackages = [ "vscode" ];
    
    theming.fonts.extraFonts = [
      cfg.codeFont
    ];

    programs.vscode = {
      enable = true;

      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions; [
        eamodio.gitlens
      ];

      userSettings = {
        # Font setup
        # TODO: Move the conversion factor to theme settings
        "editor.fontFamily" = mkForce "'${cfg.codeFont.name}', '${cfg.fallbackFont.name}'";
        "editor.fontSize" = mkForce (cfg.codeFont.recommendedSize); # Convert pt to px 
        "editor.fontLigatures" = true;
        "terminal.integrated.fontFamily" = mkForce "'${cfg.codeFont.name}', '${cfg.fallbackFont.name}'";
        "terminal.integrated.fontSize" = mkForce (cfg.codeFont.recommendedSize); # Convert pt to px
        
        # Formatting
        "editor.formatOnSave" = true;
        "editor.tabSize" = 4;

        # Layout
        "window.menuBarVisibility" = "hidden";
      };
    };
  };
}