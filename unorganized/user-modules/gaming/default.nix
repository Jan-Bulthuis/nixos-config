{ ... }:

{
  imports = [
    ./emulators/pcsx2.nix
    ./emulators/retroarch.nix
    ./emulators/ryujinx.nix
    ./launchers/es-de.nix
    ./launchers/modrinth.nix
    ./launchers/steam.nix
  ];
}
