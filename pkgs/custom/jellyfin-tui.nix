{
  fetchFromGitHub,
  lib,
  linux-pam,
  rustPlatform,
  testers,
  lemurs,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "jellyfin-tui";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "dhonus";
    repo = "jellyfin-tui";
    rev = "v${version}";
    hash = "sha256-jHjTckdyPMJO1INF1AdJvvWTJ0ZJJGOxkBc0YZx9HWI=";
  };

  cargoHash = "sha256-H6JTupGh1ec6/RIkoAPMl2agNSbF9B5CuJlxDNEwDc4=";

  buildInputs = with pkgs; [
    mpv
  ];

  nativeBuildInputs = with pkgs; [
    pkg-config
    openssl
    openssl.dev
  ];

  desktopItems =
    let
      desktopEntry = pkgs.makeDesktopItem {
        name = "siyuan";
        desktopName = "SiYuan";
        comment = "Refactor your thinking";
        terminal = true;
        exec = "jellyfin-tui";
      };
    in
    [
      desktopEntry
    ];

  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

  meta = with lib; {
    description = "Jellyfin TUI music client written in Rust";
    homepage = "https://github.com/dhonus/jellyfin-tui";
    license = with licenses; [
      gpl3
    ];
    maintainers = with maintainers; [ ];
    mainProgram = "jellyfin-tui";
  };
}
