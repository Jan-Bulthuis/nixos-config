{
  description = "System configuration for NixOS";

  inputs = {
    glue.url = "./glue";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.glue { inherit inputs; };
}
