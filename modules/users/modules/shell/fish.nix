{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.fish;
in
{
  options.modules.fish = {
    enable = mkEnableOption "fish";

    plugins = {
      done = mkEnableOption "done";
      fzf = mkEnableOption "fzf";
      grc = mkEnableOption "grc";
    };
  };

  config = mkIf cfg.enable {
    # Make bash load into fish
    # Bash will remain the default shell as fish is not POSIX compliant.
    modules.bash.enable = true;
    programs.bash.initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';

    # Actual fish configuration
    programs.fish = {
      enable = true;

      plugins = [
        (mkIf cfg.plugins.done {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        })
        (mkIf cfg.plugins.fzf {
          name = "fzf";
          src = pkgs.fishPlugins.fzf-fish.src;
        })
        (mkIf cfg.plugins.grc {
          name = "grc";
          src = pkgs.fishPlugins.grc.src;
        })
      ];
    };

    # Fish plugin dependencies
    home.packages = with pkgs; [
      (mkIf cfg.plugins.fzf fzf)
      (mkIf cfg.plugins.grc grc)
    ];
  };
}
