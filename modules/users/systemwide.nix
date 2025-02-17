{
  config,
  lib,
  ...
}:

with lib;
let
  moduleFiles = [
    ../../user-modules/desktop/systemwide.nix
    ../../user-modules/development/systemwide.nix
    ../../user-modules/gaming/systemwide.nix
    ../../user-modules/keyring/systemwide.nix
  ];

  moduleConfig = lists.foldr (file: acc: recursiveUpdate acc (import file)) { } moduleFiles;

  moduleNames = attrNames moduleConfig;

  mkModule =
    name: moduleConfig:
    { pkgs, ... }:
    {
      config = mkIf (any (user: user.modules.${name}.enable) (attrValues config.home-manager.users)) (
        if (isAttrs moduleConfig) then moduleConfig else (moduleConfig { inherit config pkgs; })
      );
    };

  imports = map (name: mkModule name moduleConfig."${name}") moduleNames;
in
{
  imports = imports;
}
