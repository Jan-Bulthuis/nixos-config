{
  lib,
  config,
  ...
}:

with lib;
{
  options.cuda = {
    enable = mkEnableOption "CUDA";
  };

  config = mkIf config.cuda.enable {

  };
}
