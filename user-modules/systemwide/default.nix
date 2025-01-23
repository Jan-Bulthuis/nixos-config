{ ... }:

{
  imports = [
    # Import systemwide configuration files.
    ./docker.nix
    ./river.nix
    ./steam.nix
    ./waylock.nix
  ];
}
