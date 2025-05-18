{
  pkgs,
  ...
}:

{
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    libreoffice-still
    remmina
    thunderbird
    signal-desktop
    prusa-slicer
    freecad-wayland
    inkscape
    ente-auth
    bitwarden
    carla
    winbox
    whatsapp-for-linux
    discord
    steam
    spotify
    # feishin # TODO: Fix or replace as insecure
    eduvpn-client
    river # TODO: Move
    firefox # TODO: Move to dediated module
    ryubing
    dconf-editor
    bottles
  ];

  modules = {
    # Desktop environment
    desktop.gnome.enable = true;
    # desktop.tiling.enable = true;

    # Browser
    # firefox = {
    #   enable = true;
    #   default = false;
    # };
    # qutebrowser = {
    #   enable = true;
    #   default = true;
    # };

    # Gaming
    # retroarch.enable = true;
    # ryujinx.enable = true;

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
    # btop.enable = true;
    direnv.enable = true;
    fish.enable = true;
    # bluetuith.enable = false;
    # obsidian.enable = true;
    # zathura.enable = true;
    # keyring.enable = true;
    # scripts.enable = true;
    xpra = {
      enable = true;
      hosts = [
        "mixer@10.20.60.251"
      ];
    };

    # Development
    # neovim.enable = true;
    vscode.enable = true;
    # docker.enable = true;
    # matlab.enable = true;
    # mathematica.enable = true;

    # Languages
    haskell.enable = false;
    js.enable = true;
    nix.enable = true;
    rust.enable = true;
    python.enable = true;
    cpp.enable = true;
    tex.enable = true;
    jupyter.enable = false;
  };
}
