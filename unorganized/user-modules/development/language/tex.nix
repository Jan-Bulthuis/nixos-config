{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.tex;
in
{
  options.modules.tex = {
    enable = mkEnableOption "tex";
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = with pkgs; [
      (texlive.combine {
        inherit (texlive) scheme-full;
      })
    ];

    # Pygments for minted
    modules.python.extraPythonPackages = p: [
      p.pygments
    ];

    # VSCode configuration
    programs.vscode = {
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [ jnoortheen.nix-ide ];

        userSettings = {
          "[tex]" = { };
        };
      };
    };

    # Neovim configuration
    programs.nixvim = {
      extraConfigVim = ''
        " Enforce latexmk
        let g:vimtex_compiler_method = 'latexmk'

        " Set latexmk compilation settings
        let g:vimtex_compiler_latexmk = {
          \ 'options': [
          \   '-shell-escape',
          \   '-verbose',
          \   '-file-line-error',
          \   '-synctex=1',
          \   '-interaction=nonstopmode',
          \ ],
          \}
      '';

      # Vimtex plugin
      plugins.vimtex = {
        enable = true;
        texlivePackage = null;
        settings = {
          view_method = "zathura";
        };
      };
    };
  };
}
