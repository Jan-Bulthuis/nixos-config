{
  pkgs,
  pkgs-stable,
  lib,
  config,
  inputs,
  ...
}:

with lib;
let
  cfg = config.modules.profiles.jan;
in
{
  options.modules.profiles.jan = {
    enable = mkEnableOption "Jan's personal profile";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      firefox
      # inputs.stable-nixpkgs.legacyPackages.${config.nixpkgs.hostPlatform}.libreoffice
      libreoffice
      remmina
      thunderbird
      signal-desktop
      prusa-slicer
      freecad-wayland
      inkscape
      # ente-auth
      audacity
      carla
      # pkgs-stable.winbox
      winbox4
      # whatsapp-for-linux
      wasistlos
      discord
      steam
      spotify
      # feishin
      eduvpn-client
      ryubing
      bottles
      prismlauncher
      foliate
      wireshark
      obsidian
      # devenv
      # kicad
      vlc
      authenticator

      podman
      podman-compose

      gnome-network-displays
      gnome-logs
    ];

    programs.helix = {
      enable = true;
      defaultEditor = true;
      # settings = {
      #   theme = {
      #     light = "adwaita-light";
      #     dark = "adwaita-dark";
      #     fallback = "default";
      #   };
      # };
      extraPackages = with pkgs; [
        bash-language-server # Bash
        fish-lsp # Fish
        systemd-lsp # Systemd
        yaml-language-server # Yaml
        taplo # Toml
        nixd # Nix
        protols # Protobuf
        dockerfile-language-server # Dockerfile
        docker-compose-language-service # Docker compose

        clang-tools # C, C++
        neocmakelsp # Cmake
        rust-analyzer # Rust
        lldb # C, C++, Rust
        zls # Zig

        texlab # Latex
        tinymist # Typst
        marksman # Markdown
        markdown-oxide # Markdown
        vscode-langservers-extracted # HTML, CSS, JSON, ESLint
        typescript-language-server # Typescript, Javascript
        intelephense # PHP
        vue-language-server # Vue

        ruff # Python
        basedpyright # Python

        helix-gpt # Copilot

        # texlab # Latex, Bibtex
        # bibtex-tidy # Bibtex
        # docker-langserver # Dockerfile
        # docker-compose-langserver # Docker compose
        # elixir-ls # Elixir
        # gopls # Go
        # golangci-lint-langserver # Go
        # dlv # Go
        # haskell-language-server # Haskell
        # julia # Julia
        # kotlin-language-server # Kotlin
        # lua-language-server # Lua
        # slint-lsp # Slint
        # tinymist # Typst
      ];
      languages = {
        language-server = {
          basedpyright = {
            command = "basedpyright-langserver";
            args = [ "--stdio" ];
          };
          tinymist = {
            command = "tinymist";
            config.preview.background = {
              enabled = true;
              args = [
                "--data-plane-host=127.0.0.1:23635"
                "--invert-colors=never"
                "--open"
              ];
            };
          };
        };
        language = [
          {
            name = "python";
            language-servers = [
              {
                name = "basedpyright";
                except-features = [ "diagnostics" ];
              }
              "ruff"
            ];
            auto-format = true;
            formatter = {
              command = "ruff";
              args = [
                "format"
                "-"
              ];
            };
          }
        ];
      };
    };

    modules = {
      profiles.gnome.enable = true;

      impermanence = {
        directories = [
          "Code"
          "Documents"
          "Games"
          "Models"
          "Music"
          "Pictures"
          "Videos"
        ];
      };

      # Gaming
      # retroarch.enable = true;
      # ryujinx.enable = true;

      # Tools
      git = {
        enable = true;
        user = "Jan-Bulthuis";
        email = "git@bulthuis.dev";
        # TODO: Move
        ignores = [
          ".envrc"
          ".direnv"
          "flake.nix"
          "flake.lock"
        ];
      };
      bitwarden.enable = true;
      xpra = {
        enable = true;
        hosts = [
          "mixer@10.20.40.100"
        ];
      };

      # Development
      # docker.enable = true;
      # matlab.enable = true;
      # mathematica.enable = true;

      # Languages
      haskell.enable = false;
      js.enable = true;
      nix.enable = true;
      rust.enable = true;
      python.enable = true;
      cpp.enable = true;
      tex.enable = false;
      jupyter.enable = true;
      go.enable = true;
    };
  };
}
