{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = mkEnableOption "git";

    user = mkOption {
      type = types.str;
      description = "Default user name to use.";
    };

    email = mkOption {
      type = types.str;
      description = "Default user email to use.";
    };

    ignores = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Paths to globally ignore";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      lazygit
    ];

    programs.git = {
      enable = true;

      extraConfig = {
        pull = {
          rebase = false;
        };
      };

      userName = cfg.user;
      userEmail = cfg.email;
      ignores = cfg.ignores;
    };
  };
}
