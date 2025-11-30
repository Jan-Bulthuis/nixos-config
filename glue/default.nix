inputs:
let
  flake = inputs.self;
  nixpkgs = inputs.nixpkgs;
  lib = nixpkgs.lib;

  nixpkgs-config = {
    allowUnfree = true;
  };

  importDir =
    path: fn:
    let
      entries = builtins.readDir path;

      # Get paths to directories
      dirs = lib.filterAttrs (_: type: type == "directory") entries;
      dirPaths = lib.mapAttrs (name: type: {
        path = "${path}/${name}";
        type = type;
      }) dirs;

      # Get paths to nix files
      nixName = name: builtins.match "(.*)\\.nix" name;
      files = lib.filterAttrs (name: type: (type != "directory") && ((nixName name) != null)) entries;
      filePaths = lib.mapAttrs' (name: type: {
        name = builtins.head (nixName name);
        value = {
          path = "${path}/${name}";
          type = type;
        };
      }) files;

      combined = dirPaths // filePaths;
    in
    fn (lib.optionalAttrs (builtins.pathExists path) combined);

  # Split out into getNixFiles, getNixFilesRecursive, getDirs
  importDirRecursive =
    path: fn:
    let
      entries = importDir path lib.id;

      # Dig down recursively
      dirs = lib.filterAttrs (_: entry: entry.type == "directory") entries;
      recursedEntries = lib.mapAttrs (name: entry: (importDirRecursive entry.path lib.id)) dirs;
    in
    fn (entries // recursedEntries);

  eachSystem = fn: lib.genAttrs lib.systems.flakeExposed fn;

  systemArgs = eachSystem (system: {
    pkgs = (
      import inputs.nixpkgs {
        inherit system;
        config = nixpkgs-config;
      }
    );
    stable-pkgs = (
      import inputs.nixpkgs-stable {
        inherit system;
        config = nixpkgs-config;
      }
    );
  });

  allPackages = importDir "${flake}/packages" (
    attrs:
    lib.mapAttrs (
      name: entry: (if entry.type == "directory" then "${entry.path}/default.nix" else entry.path)
    ) attrs
  );

  packages =
    let
      # TODO: Filter out packages that are not supported on the platform?
      mkPackages =
        system:
        let
          args = systemArgs."${system}";
          pkgs = args.pkgs;
        in
        lib.mapAttrs (name: package: pkgs.callPackage package { }) allPackages;
    in
    eachSystem mkPackages;

  overlay = final: prev: (lib.mapAttrs (name: package: prev.callPackage package { }) allPackages);

  collectEntries =
    attrs:
    lib.attrsets.collect (
      entry: (lib.isAttrs entry) && (lib.hasAttr "path" entry) && (lib.hasAttr "type" entry)
    ) attrs;

  collectModules =
    path:
    importDirRecursive path (
      attrs:
      map (entry: if entry.type == "directory" then entry.path + "/default.nix" else entry.path) (
        collectEntries attrs
      )
    );

  nixosModules = collectModules "${flake}/modules/nixos";
  nixosProfiles = collectModules "${flake}/profiles/nixos";
  inputNixosModules = lib.map (flake: flake.outputs.nixosModules.default) (
    lib.filter (flake: lib.hasAttrByPath [ "outputs" "nixosModules" "default" ] flake) (
      lib.attrValues inputs
    )
  );

  homeModules = collectModules "${flake}/modules/home";
  homeProfiles = collectModules "${flake}/profiles/home";
  inputHomeModules = lib.map (flake: flake.outputs.homeManagerModules.default) (
    lib.filter (flake: lib.hasAttrByPath [ "outputs" "homeManagerModules" "default" ] flake) (
      lib.attrValues inputs
    )
  );

  inputOverlays = lib.map (flake: flake.outputs.overlays.default) (
    lib.filter (flake: lib.hasAttrByPath [ "outputs" "overlays" "default" ] flake) (
      lib.attrValues inputs
    )
  );

  overlayModule =
    { ... }:
    {
      nixpkgs.overlays = [ overlay ] ++ inputOverlays;
    };

  nixpkgsModule =
    { ... }:
    {
      nixpkgs.config = nixpkgs-config;
    };

  nixosConfigurations = importDir "${flake}/hosts" (
    attrs:
    lib.mapAttrs (
      name: entry:
      let
        pkgs-stable = systemArgs."x86_64-linux".stable-pkgs;
      in
      lib.nixosSystem {
        specialArgs = {
          inherit inputs pkgs-stable;
        };
        modules =
          let
            systemPath = "${entry.path}/configuration.nix";

            userEntries = importDir "${entry.path}/users" lib.id;

            usersConfiguration = lib.mapAttrs (name: entry: {
              isNormalUser = true;
              group = name;
            }) userEntries;
            groupsConfiguration = lib.mapAttrs (name: entry: {
            }) userEntries;
            homesConfiguration = lib.mapAttrs (name: entry: entry.path) userEntries;

            usersModule =
              { ... }:
              {
                home-manager.extraSpecialArgs = {
                  inherit inputs pkgs-stable;
                };
                home-manager.sharedModules = homeModules ++ homeProfiles ++ inputHomeModules;
                home-manager.useUserPackages = true;
                home-manager.useGlobalPkgs = true;
                home-manager.users = homesConfiguration;
                users.users = usersConfiguration;
                users.groups = groupsConfiguration;
              };
          in
          [
            systemPath
            overlayModule
            usersModule
            nixpkgsModule
          ]
          ++ nixosModules
          ++ nixosProfiles
          ++ inputNixosModules;
      }
    ) (lib.attrsets.filterAttrs (name: entry: entry.type == "directory") attrs)
  );

in
{
  inherit packages nixosConfigurations overlay;
  overlays.default = overlay;
}
