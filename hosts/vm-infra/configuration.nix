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
    nat64.default = {
      global.pool6 = "64:ff9b::/96";
      pool4 = [
        {
          protocol = "TCP";
          prefix = "10.64.0.1/32";
        }
        {
          protocol = "UDP";
          prefix = "10.64.0.1/32";
        }
        {
          protocol = "ICMP";
          prefix = "10.64.0.1/32";
        }
      ];
    };
  };
}
