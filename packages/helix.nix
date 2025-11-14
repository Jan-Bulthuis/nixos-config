{
  fetchFromGitHub,
  fetchzip,
  lib,
  rustPlatform,
  git,
  installShellFiles,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (final: rec {
  pname = "helix";
  version = "25.07.1";

  # This release tarball includes source code for the tree-sitter grammars,
  # which is not ordinarily part of the repository.
  src = fetchFromGitHub {
    owner = "helix-editor";
    repo = "helix";
    rev = "109c812233e442addccf1739dec4406248bd3244";
    hash = "sha256-c3fpREWUKGonlmV/aesmyRxbJZQypHgXStR7SwdcCo0=";
  };
  grammars = fetchzip {
    url = "https://github.com/helix-editor/helix/releases/download/${final.version}/helix-${final.version}-source.tar.xz";
    hash = "sha256-Pj/lfcQXRWqBOTTWt6+Gk61F9F1UmeCYr+26hGdG974=";
    stripRoot = false;
  };

  cargoHash = "sha256-g5MfCedLBiz41HMkIHl9NLWiewE8t3H2iRKOuWBmRig=";

  nativeBuildInputs = [
    git
    installShellFiles
  ];

  env.HELIX_DEFAULT_RUNTIME = "${placeholder "out"}/lib/runtime";

  patchPhase = ''
    # Add the runtime data
    rm -r runtime
    cp ${grammars}/languages.toml languages.toml
    cp -r ${grammars}/runtime runtime
    chmod -R u+w runtime
  '';

  postInstall = ''
    # not needed at runtime
    rm -r runtime/grammars/sources

    mkdir -p $out/lib
    cp -r runtime $out/lib
    installShellCompletion contrib/completion/hx.{bash,fish,zsh}
    mkdir -p $out/share/{applications,icons/hicolor/256x256/apps}
    cp contrib/Helix.desktop $out/share/applications
    cp contrib/helix.png $out/share/icons/hicolor/256x256/apps
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgram = "${placeholder "out"}/bin/hx";
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Post-modern modal text editor";
    homepage = "https://helix-editor.com";
    changelog = "https://github.com/helix-editor/helix/blob/${final.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    mainProgram = "hx";
    maintainers = with lib.maintainers; [
      danth
      yusdacra
      zowoq
    ];
  };
})
