{ ... }:

{
    imports = [
        # Import modules
        ./modules/default.nix

        # Import custom packages
        ./pkgs/default.nix
    ];
}