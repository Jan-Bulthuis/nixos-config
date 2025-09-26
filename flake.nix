{
  description = "System configuration for NixOS";

  inputs = {
    # General inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    secrets.url = "git+ssh://gitea@git.bulthuis.dev/Jan/nixos-secrets";

    # Disk setup
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";

    # MADD
    madd.url = "git+https://git.bulthuis.dev/Jan/madd";
    madd.inputs.nixpkgs.follows = "nixpkgs";

    # For Minecraft VM
    nix-minecraft.url = "github:Jan-Bulthuis/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
    nix-modpack.url = "github:Jan-Bulthuis/nix-modpack";
    nix-modpack.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: import ./glue inputs;
}
