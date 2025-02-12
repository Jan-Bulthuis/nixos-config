{
  stdenv,
  lib,
  fetchFromGitHub,
  linux-pam,
  libxcb,
  makeBinaryWrapper,
  zig_0_12,
  callPackage,
  nixosTests,
}:

stdenv.mkDerivation {
  pname = "ly";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "peterc-s";
    repo = "ly";
    rev = "e6d8bea236dd0097adb1c22e9a23d95102ebe9d9";
    sha256 = "w9YdNVD+8UhrEbPJ7xqsd/WoxU2rlo2GXFtc9JpWHxo=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    zig_0_12.hook
  ];
  buildInputs = [
    libxcb
    linux-pam
  ];

  postPatch = ''
    ln -s ${callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
  '';

  passthru.tests = { inherit (nixosTests) ly; };

  meta = with lib; {
    description = "TUI display manager";
    license = licenses.wtfpl;
    homepage = "https://github.com/fairyglade/ly";
    maintainers = [ maintainers.vidister ];
    platforms = platforms.linux;
    mainProgram = "ly";
  };
}
