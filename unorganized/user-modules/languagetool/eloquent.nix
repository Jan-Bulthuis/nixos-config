{ lib, config, ... }:

with lib;
{
  options.modules.eloquent = {
    enable = mkEnableOption "eloquent";
  };

  config = mkIf config.modules.eloquent.enable {
    modules.flatpak.enable = true;

    services.flatpak.packages = [
      "flathub:app/re.sonny.Eloquent//stable"
      "flathub:app/org.kde.kdenlive//stable"
    ];
  };
}
