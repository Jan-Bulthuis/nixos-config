{ pkgs, ... }:

with pkgs;
rustPlatform.buildRustPackage {
  pname = "carla_osc_bridge";
  version = "master";

  src = fetchFromGitea {
    domain = "git.bulthuis.dev";
    owner = "Jan";
    repo = "carla_osc_bridge";
    rev = "8966a25e8d56efa30a28fd320c6f657040a1f01c";
    hash = "sha256-AJ+hb642V/aqizbM4URaZhFSIFwSvGa23HIkHqIru2o=";
  };

  cargoHash = "sha256-s1ZKbhHudgPOy7613zbT8TkbM6B7oloLEuTYHoWjX5o=";

  useFetchCargoVendor = true;
}
