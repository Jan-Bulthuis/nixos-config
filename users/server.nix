# How Jan likes his linux to be configured on servers

{
  pkgs,
  ...
}:

{
  config = {
    # State version
    home.stateVersion = "24.11";

    # TODO: Move into modules
    home.packages = with pkgs; [
      libreoffice-still
      remmina
      pinentry
      thunderbird
      signal-desktop
      prusa-slicer
      freecad-wayland
      inkscape
      ente-auth
      bitwarden
    ];

    # Enabled modules
    modules = {
      # Tools
      git = {
        enable = true;
        user = "Jan-Bulthuis";
        email = "git@bulthuis.dev";
        # TODO: Move
        ignores = [
          ".envrc"
          ".direnv"
          "flake.nix"
          "flake.lock"
        ];
      };
      btop.enable = true;
      fish.enable = true;
      keyring.enable = true;
      scripts.enable = true;

      # Development
      neovim.enable = true;

      # Languages
      haskell.enable = false;
      js.enable = true;
      nix.enable = true;
      rust.enable = true;
      python.enable = true;
      cpp.enable = true;

      # Enable unfree
      unfree.enable = true;
    };
  };
}
