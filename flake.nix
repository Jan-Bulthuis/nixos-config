{
  description = "NixOS system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    nixvim.url = "github:nix-community/nixvim";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      stylix,
      nixvim,
      nur,
      nix-matlab,
      ...
    }:
    let
      makeConfig =
        machineConfig: userConfig:
        (nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            machineConfig
            home-manager.nixosModules.home-manager
            {
              machine.users = userConfig;
              home-manager.sharedModules = [
                stylix.homeManagerModules.stylix
                nixvim.homeManagerModules.nixvim
                nur.modules.homeManager.default
                {
                  # TODO: Remove insecure package exception
                  nixpkgs.config.permittedInsecurePackages = [
                    "freeimage-unstable-2021-11-01" # For emulation station
                    "electron-31.7.7" # For feishin
                  ];
                  nixpkgs.overlays = [
                    nix-matlab.overlay
                  ];
                }
              ];
            }
          ];
        });
    in
    {
      nixosConfigurations = {
        "20212060" = makeConfig ./machines/laptop.nix {
          jan = {
            sudo = true;
            configuration = ./users/jan.nix;
          };
        };
      };
    };
}
