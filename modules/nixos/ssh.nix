{ lib, config, ... }:

with lib;
let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = {
    enable = mkEnableOption "ssh";
  };
  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
      hostKeys = mkIf (config.modules.impermanence.enable) [
        {
          type = "ed25519";
          path = "/persist/system/etc/ssh/ssh_host_ed25519_key";
        }
        {
          type = "rsa";
          bits = 4096;
          path = "/persist/system/etc/ssh/ssh_host_rsa_key";
        }
      ];
    };
  };
}
