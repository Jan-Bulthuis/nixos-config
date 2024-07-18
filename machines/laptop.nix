{ ... }:

{
  imports = [
    # Import modules
    ../modules/default.nix

    # TODO: Remove later
    ../merged.nix
  ];

  config = {
    # State version
    system.stateVersion = "24.05";

    # Machine hostname
    networking.hostName = "20212060";

    # Enabled modules
    modules = {
      pipewire.enable = true;
      wpa_supplicant.enable = true;
    };

    # User accounts
    machine.users.jan = {
      sudo = true;
      configuration = ../users/jan.nix;
    };
  };
}