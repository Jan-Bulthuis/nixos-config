{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    (python312.withPackages (p: [
      p.numpy
      p.scikit-learn
      p.scipy
      p.pandas
      p.matplotlib
      p.torch-bin
      # p.torchvision
    ]))
    libffi
    openssl
    stdenv.cc.cc
    linuxPackages.nvidia_x11
    binutils
    cudatoolkit
    libGLU
    libGL
  ];
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
    with pkgs;
    [
      stdenv.cc.cc
      linuxPackages.nvidia_x11
      binutils
      cudatoolkit
      libGLU
      libGL
    ]
  );
  CUDA_PATH = pkgs.cudatoolkit;
}
