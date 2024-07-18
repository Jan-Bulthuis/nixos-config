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
  };

  config = mkIf cfg.enable {
    modules.unfree.allowedPackages = [ "vscode" ];
    
    theming.fonts.extraFonts = [
      cfg.codeFont
    ];

    programs.vscode = {
      enable = true;

      extensions = with pkgs.vscode-extensions; [
        eamodio.gitlens

        # Language support
        # TODO: Move to separate language modules
        bbenoist.nix
        rust-lang.rust-analyzer
      ];

      userSettings = {
        # Font setup
        "editor.fontFamily" = mkForce cfg.codeFont.name;
        "editor.fontSize" = cfg.codeFont.recommendedSize;
        "editor.fontLigatures" = true;
        "terminal.integrated.fontFamily" = mkForce cfg.codeFont.name; 
        "terminal.integrated.fontSize" = cfg.codeFont.recommendedSize;
        
        # Autoformatting
        "editor.formatOnSave" = true;
      };
    };
  };
}