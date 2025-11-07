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
        address = "10.64.0.0";
        prefixLength = 16;
      };
    };
    ipv6 = {
      router = {
        address = "64::ff9b::1";
      };
      pool = {
        address = "64:ff9b::";
        prefixLength = 96;
      };
    };
  };
}
