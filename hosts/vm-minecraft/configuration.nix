{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

{
  # State version
  system.stateVersion = "24.11";

  # Import the nix-minecraft modules
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  # Machine hostname
  networking.hostName = "vm-minecraft";

  # Enabled modules
  modules = {
    profiles.vm.enable = true;
  };

  # Set up minecraft servers
  users.users.local.extraGroups = [ "minecraft" ];
  modules.impermanence.directories = [
    "/srv/minecraft"
  ];
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers = {
      vanilla = {
        enable = true;
        autoStart = true;
        serverProperties = {
          white-list = true;
        };
        package = inputs.nix-minecraft.legacyPackages.${pkgs.system}.vanillaServers.vanilla-1_21_7;
      };
      modpack = {
        enable = false;
        autoStart = true;
        serverProperties = { };
        package = inputs.nix-modpack.packages.${pkgs.system}.mkModpackServer {
          packUrl = "https://raw.githubusercontent.com/Jan-Bulthuis/Modpack/refs/heads/master/pack.toml";
          server = inputs.nix-minecraft.legacyPackages.${pkgs.system}.neoForgeServers.neoforge-20_1_106;
        };
        jvmOpts = "-Xms6144M -Xmx8192M";
      };
    };
  };
}
