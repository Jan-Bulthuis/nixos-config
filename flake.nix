{
  description = "NixOS system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      nixvim,
      nur,
      nix-matlab,
      ...
    }:
    let
      mkConfig =
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
        "20212060" = mkConfig ./machines/laptop.nix {
          jan = {
            sudo = true;
            configuration = ./users/jan.nix;
          };
        };
      };
      lib = import ./shell-modules/default.nix self.inputs;
    };
}
