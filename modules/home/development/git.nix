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

    signingKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to the SSH public key used to sign commits and tags.";
    };

    allowedSigners = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Trusted signers for verifying SSH signatures, as \"<email> <public key>\" lines.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      lazygit
    ];

    programs.git = {
      enable = true;

      settings = {
        pull = {
          rebase = false;
        };
      };

      settings.user.name = cfg.user;
      settings.user.email = cfg.email;
      ignores = cfg.ignores;

      signing = mkIf (cfg.signingKey != null) {
        format = "ssh";
        key = cfg.signingKey;
        signByDefault = true; # commit.gpgsign and tag.gpgSign
      };

      settings.gpg.ssh.allowedSignersFile = mkIf (cfg.allowedSigners != [ ]) (
        toString (pkgs.writeText "git-allowed-signers" (concatLines cfg.allowedSigners))
      );
    };
  };
}
