{
  steam =
    { pkgs, ... }:
    {
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
