{
  inputs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.secrets;
  secrets = inputs.secrets;
in
{
  options.modules.secrets = {
    enable = mkEnableOption "secrets";
    defaultFile = mkOption {
      type = types.str;
      default = "${secrets}/secrets/common.enc.yaml";
      description = ''
        The default file to use for SOPS.
      '';
    };
    secrets = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        All secrets that should be made available.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Set up SOPS
    # TODO: Fix the key not being present in /etc/sops before sops-nix runs
    sops.defaultSopsFile = cfg.defaultFile;
    sops.age.sshKeyPaths = [
      "/etc/sops/sops_ed25519_key"
      "/persist/system/etc/sops/sops_ed25519_key"
    ];
    sops.secrets = cfg.secrets;
    modules.impermanence.directories = [ "/etc/sops" ];
    virtualisation.vmVariantWithDisko.sops.age.sshKeyPaths = [ "/tmp/shared/sops_ed25519_key" ];
  };
}
