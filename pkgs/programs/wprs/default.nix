{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libxkbcommon,
  python3,
  runCommand,
  wprs,
}:
rustPlatform.buildRustPackage {
  pname = "wprs";
  version = "0-unstable-2025-04-16";

  src = fetchFromGitHub {
    owner = "wayland-transpositor";
    repo = "wprs";
    rev = "dfc1385bcb73734cd0d05a7e353522983c236562";
    hash = "sha256-MrfYrKAVFoT453B2zED6Ax2coZ/KZ7CWYdZCx469Q/4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
    (python3.withPackages (pp: with pp; [ psutil ]))
  ];

  useFetchCargoVendor = true;
  cargoHash = "sha256-01PTfgDeagC72z8XADXEn5Aio6UWQAAYgDP4zKFTPpY=";

  preFixup = ''
    cp  wprs "$out/bin/wprs"
  '';

  passthru.tests.sanity = runCommand "wprs-sanity" { nativeBuildInputs = [ wprs ]; } ''
    ${wprs}/bin/wprs -h > /dev/null && touch $out
  '';

  meta = with lib; {
    description = "rootless remote desktop access for remote Wayland";
    license = licenses.asl20;
    maintainers = with maintainers; [ mksafavi ];
    platforms = [ "x86_64-linux" ]; # The aarch64-linux support is not implemented in upstream yet. Also, the darwin platform is not supported as it requires wayland.
    homepage = "https://github.com/wayland-transpositor/wprs";
    mainProgram = "wprs";
  };
}
