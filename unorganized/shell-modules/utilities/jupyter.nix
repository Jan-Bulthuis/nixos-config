{
  lib,
  config,
  ...
}:

with lib;
{
  options.jupyter = {
    enable = mkEnableOption "Jupyter";
  };

  config = mkIf config.jupyter.enable {
    python.enable = mkDefault true;
    python.packages =
      p: with p; [
        jupyter
        notebook
        ipykernel
      ];
  };
}
