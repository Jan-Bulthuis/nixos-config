{
  pkgs,
  ...
}:

{
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
  ];

  modules = {
    # Desktop environment
    # desktop.gnome.enable = true;
    # desktop.tiling.enable = true;
  };
}
