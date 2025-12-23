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

      shellAliases = config.modules.bash.aliases;

      plugins = [
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        {
          name = "fzf";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        {
          name = "grc";
          src = pkgs.fishPlugins.grc.src;
        }
      ];
    };

    # Fish plugin dependencies
    home.packages = with pkgs; [
      fzf
      grc
    ];

    # Impermanence
    modules.impermanence.files = [ ".local/share/fish/fish_history" ];
  };
}
