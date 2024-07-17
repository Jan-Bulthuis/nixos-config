{ ... }:

{
  imports = [
    # Import base configuration
    ./base.nix
  ];

  config = {
    modules.zathura.enable = true; 
  };
}