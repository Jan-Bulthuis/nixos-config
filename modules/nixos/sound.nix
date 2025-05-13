{ lib, config, ... }:

with lib;
let
  cfg = config.modules.sound;
in
{
  options.modules.sound = {
    enable = mkEnableOption "sound";
  };
  config = mkIf cfg.enable {
    # Enable pipewire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Recommended by wiki, allows user processes to use realtime kernel
    security.rtkit.enable = true;
  };
}
