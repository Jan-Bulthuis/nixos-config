{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.scripts;
in
{
  options.modules.scripts.enable = mkEnableOption "scripts";

  config = mkIf cfg.enable {
    # home.packages = with pkgs; map (path: (writeShellScriptBin "${path}" (readFile path))) scripts;
    home.packages = with pkgs; [
      (writeShellScriptBin "mkenv" (readFile ./mkenv.sh))
    ];
  };
}
