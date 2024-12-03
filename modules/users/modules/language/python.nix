{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.python;
  package = pkgs.python3.withPackages cfg.extraPythonPackages;
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
    home.packages = [
      package
    ];

    # Allow unfree
    modules.unfree.allowedPackages = [
      "vscode-extension-MS-python-vscode-pylance"
    ];

    # VSCode configuration
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-python.debugpy
        ms-python.vscode-pylance
        ms-python.black-formatter
      ];

      userSettings = {
        "[python]" = {
          "editor.defaultFormatter" = "ms-python.black-formatter";
        };
      };
    };

    # Neovim configuration
    programs.nixvim = { };
  };
}
