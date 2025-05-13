{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.python;
in
{
  options.modules.python = {
    enable = mkEnableOption "python";
    extraPythonPackages = mkOption {
      type = types.functionTo (types.listOf types.package) // {
        merge =
          loc: defs: p:
          lib.concatMap (def: (def.value p)) defs;
      };
      default = p: [ ];
      description = "Extra Python packages to install";
    };
  };

  config = mkIf cfg.enable {
    # Development packages
    home.packages = [ ];

    # VSCode configuration
    programs.vscode = {
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          ms-python.python
          ms-python.debugpy
          ms-python.vscode-pylance
          ms-python.black-formatter
        ];

        userSettings = {
          "python.defaultInterpreterPath" = "\${env:PYTHONINTERPRETER}";
          "[python]" = {
            "editor.defaultFormatter" = "ms-python.black-formatter";
          };
        };
      };
    };

    # Neovim configuration
    # programs.nixvim = { };
  };
}
