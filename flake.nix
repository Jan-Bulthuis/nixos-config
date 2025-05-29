{
  description = "System configuration for NixOS";

  inputs = {
    # General inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";

    # For Minecraft VM
    nix-minecraft.url = "github:Jan-Bulthuis/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
    nix-modpack.url = "github:Jan-Bulthuis/nix-modpack";
    nix-modpack.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: import ./glue inputs;
}
