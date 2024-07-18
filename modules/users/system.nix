{ lib, config, pkgs, ... }:

with lib;
let
  users = config.home-manager.users;
  allModules = flatten (map (user: (attrValues user.modules)) (attrValues users));
  modules = filter (module: module?system && module?enable) allModules;
  configs = map (module: module.system) modules;
  combined = (foldl (a: b: recursiveUpdate a b) {} configs);
in {
  # Add the combined systemwide config required by the user modules.
  config = combined;
}