{
  lib,
  pkgs,
  config,
  ...
}:

{
  # State version
  system.stateVersion = "24.11";

  # Machine hostname
  networking.hostName = "vm-test";

  # Enabled modules
  modules = {
    profiles.vm.enable = true;
  };
}
