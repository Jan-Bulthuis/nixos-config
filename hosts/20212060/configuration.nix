{ flake, ... }:

{
  # State version
  system.stateVersion = "24.05";

  # Machine hostname
  networking.hostName = "20212060";

  # Admin users
  users.users.jan.extraGroups = [ "wheel" ];

  virtualisation.libvirtd.enable = true;

  modules = {
    profiles.laptop.enable = true;
  };

  imports = [
    ./hardware-configuration.nix
  ];
}
