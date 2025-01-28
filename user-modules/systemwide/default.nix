{ ... }:

{
  imports = [
    # Import systemwide configuration files.
    ./docker.nix
    ./keyring.nix
    ./river.nix
    ./steam.nix
    ./waylock.nix
  ];
}
