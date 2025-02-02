{ ... }:

{
  imports = [
    # Import systemwide configuration files.
    ./docker.nix
    ./i3.nix
    ./keyring.nix
    ./river.nix
    ./steam.nix
    ./waylock.nix
  ];
}
