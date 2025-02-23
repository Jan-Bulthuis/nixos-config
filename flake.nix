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
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
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
      nixos-cosmic,
      ...
    }:
    let
      mkConfig =
        system: machineConfig: userConfig:
        (nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit system; };
          modules = [
            machineConfig
            home-manager.nixosModules.home-manager
            {
              nix.settings = {
                substituters = [ "https://cosmic.cachix.org/" ];
                trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
              };
              machine.users = userConfig;
              home-manager.extraSpecialArgs = { inherit system; };
              home-manager.sharedModules = [
                stylix.homeManagerModules.stylix
                nixvim.homeManagerModules.nixvim
                nur.modules.homeManager.default
                {
                  nixpkgs.overlays = [
                    nix-matlab.overlay
                    nixos-cosmic.overlays.default
                  ];
                }
              ];
            }
          ];
        });
    in
    {
      nixosConfigurations = {
        "20212060" = mkConfig "x86_64-linux" ./machines/laptop.nix {
          jan = {
            sudo = true;
            configuration = ./users/jan.nix;
          };
        };
      };
      lib = import ./shell-modules/default.nix self.inputs;
    };
}
