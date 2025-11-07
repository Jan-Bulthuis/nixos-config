{
  inputs,
  ...
}:

{
  # State version
  system.stateVersion = "25.05";

  # Machine hostname
  networking.hostName = "vm-infra";

  # Enabled modules
  modules = {
    profiles.vm.enable = true;
  };

  # Setup JOOL NAT64
  networking.jool = {
    enable = true;
    nat64.default = { };
  };
}
