{
  pkgs,
  lib,
  # Render node of the GPU the OpenXR runtime uses, for hybrid graphics laptops
  # (e.g. "/dev/dri/by-path/pci-0000:01:00.0-render"). Only NVIDIA is supported.
  nvidiaRenderNode ? null,
  ...
}:

# Google Chrome with WebXR over OpenXR. nixpkgs' Chromium sets checkout_openxr = false,
# so it is built without the OpenXR backend.
let
  chrome = pkgs.google-chrome;

  flags = [
    "--enable-features=OpenXR"
    # The broker reports the wrong pid to SteamVR, which then fails xrCreateInstance
    "--disable-seccomp-filter-sandbox"
    "--ozone-platform=wayland"
    "--use-angle=gl"
  ]
  ++ lib.optionals (nvidiaRenderNode != null) [
    # The compositor runs on the integrated GPU and can't import NVIDIA buffers,
    # so the window is composited in software while WebGL and WebXR stay on NVIDIA
    "--render-node-override=${nvidiaRenderNode}"
    "--disable-gpu-compositing"
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = "chrome-xr";
    exec = "chrome-xr %U";
    icon = "google-chrome";
    desktopName = "Chrome XR";
    genericName = "WebXR Browser";
    comment = "Google Chrome with WebXR through OpenXR";
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeTypes = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
in
pkgs.symlinkJoin {
  name = "chrome-xr-${chrome.version}";

  paths = [
    (pkgs.writeShellScriptBin "chrome-xr" ''
      # SteamVR's vrclient.so needs these, which NixOS doesn't provide globally
      export LD_LIBRARY_PATH=${
        lib.makeLibraryPath [
          pkgs.libuuid
          pkgs.libglvnd
        ]
      }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

      ${lib.optionalString (nvidiaRenderNode != null) ''
        # Render on the NVIDIA GPU, which the OpenXR runtime also uses
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
        export __VK_LAYER_NV_optimus=NVIDIA_only
      ''}

      # Separate profile, as the seccomp sandbox is disabled
      exec ${chrome}/bin/google-chrome-stable \
        ${lib.escapeShellArgs flags} \
        --user-data-dir="''${XDG_CONFIG_HOME:-$HOME/.config}/chrome-xr" \
        "$@"
    '')
    desktopItem
  ];

  meta = chrome.meta // {
    description = "Google Chrome with WebXR through OpenXR";
    mainProgram = "chrome-xr";
  };
}
