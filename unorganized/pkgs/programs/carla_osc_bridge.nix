{ pkgs, ... }:

with pkgs;
rustPlatform.buildRustPackage {
  pname = "carla_osc_bridge";
  version = "master";

  src = fetchFromGitea {
    domain = "git.bulthuis.dev";
    owner = "Jan";
    repo = "carla_osc_bridge";
    rev = "c037e2d2a1b29b785d8acc10fa0cb761afdb3fcf";
    hash = "sha256-Wvdfm+4dfygZwkvaUhO9w7DrrUl3ZYvtD7nYrPSD0eA=";
  };

  cargoHash = "sha256-s1ZKbhHudgPOy7613zbT8TkbM6B7oloLEuTYHoWjX5o=";

  useFetchCargoVendor = true;
}
