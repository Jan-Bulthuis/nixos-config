{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  enabled = any (user: user.modules.steam.enable) (attrValues config.home-manager.users);
in
{
  config = mkIf enabled {
    modules.unfree.allowedPackages = [
      "steam"
      "steam-original"
      "steam-unwrapped"
    ];

    programs.steam.enable = true;

    # Make steam create desktop entries in a subfolder
    programs.steam.package = pkgs.steam.override {
      extraBwrapArgs = [
        "--bind $HOME/.local/share/applications/Steam $HOME/.local/share/applications"
      ];
    };
  };
}
