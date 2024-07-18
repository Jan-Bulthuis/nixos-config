{config, lib, pkgs, ... }:

let
  cfg = config.modules.vscode;
in {
  options.modules.vscode.enable = lib.mkEnableOption "vscode";

  config = lib.mkIf cfg.enable {
    modules.unfree.allowedPackages = [ "vscode" ];
    
    home.packages = with pkgs; [
      vscode
    ];
  };
}