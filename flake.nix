{
  description = "System configuration for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-minecraft.url = "github:Jan-Bulthuis/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
    nix-modpack.url = "github:Jan-Bulthuis/nix-modpack";
    nix-modpack.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: import ./glue inputs;
}
