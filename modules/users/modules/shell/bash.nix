{ lib, config, pkgs, ... }:

with lib;
let 
  cfg = config.modules.bash;
in {
  options.modules.bash = {
    enable = mkEnableOption "bash";
  };

  config.programs.bash.enable = cfg.enable;
}