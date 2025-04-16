{ lib, config, ... }:

with lib;
{
  imports = [
    ./eloquent.nix
  ];

  options.modules.languagetool = {
    enable = mkEnableOption "languagetool";
  };

  config = mkIf config.modules.languagetool.enable {
    modules.eloquent.enable = mkDefault true;
  };
}
