{
  lib,
  config,
  ...
}:

with lib;
{
  options.modules.flatpak = {
    enable = mkEnableOption "flatpak";
    remotes = mkOption {
      type = types.attrsOf types.str;
      default = {
        flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        flathub-beta = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      };
      description = "A set of flatpak repositories to add.";
    };
  };

  config = mkIf config.modules.flatpak.enable {
    services.flatpak.enableModule = true;
    services.flatpak.remotes = config.modules.flatpak.remotes;
  };
}
