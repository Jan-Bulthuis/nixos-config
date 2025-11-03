{
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

  # Setup Tayga NAT64
  services.tayga = {
    enable = true;
    ipv4 = {
      address = "10.64.0.0";
      router = {
        address = "10.64.0.1";
      };
      pool = {
        address = "10.64.0.1";
        prefixLength = 16;
      };
    };
    ipv6 = {
      router = {
        address = "fc00:6464::1";
      };
      pool = {
        address = "fc00:6464::";
        prefixLength = 96;
      };
    };
  };
}
