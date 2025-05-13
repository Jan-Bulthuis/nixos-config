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
    services.openssh.enable = true;
    # TODO: Is this default configuration secure?
  };
}
