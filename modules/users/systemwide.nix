{
  lib,
  config,
  ...
}:

with lib;
let
  configuration = (map (user: user.systemwide) (attrValues config.home-manager.users));
in
{
  config = configuration;
}
