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
      pkgs-stable.freecad-wayland
      inkscape
      # ente-auth
      audacity
      carla
      # pkgs-stable.winbox
      winbox4
      # whatsapp-for-linux
      karere
      discord
      steam
      spotify
      # feishin
      eduvpn-client
      ryubing
      # bottles
      prismlauncher
      foliate
      wireshark
      obsidian
      # devenv
      # kicad
      vlc
      authenticator
      hotspot
      btop
      winboat
      hieroglyphic
      shortwave
      clairvoyant
      constrict
      curtail
      gnome-decoder
      dialect
      impression
      keypunch
      gnome-mahjongg
      textpieces
      video-trimmer
      wike
      davinci-resolve
      kdePackages.kdenlive
      kicad

      podman
      podman-compose

      gnome-network-displays
      gnome-logs
    ];

    programs.zathura = {
      enable = true;
      options = {
        synctex = true;
        synctex-editor-command = "${pkgs.texlab}/bin/texlab inverse-search -i %{input} -l %{line}";
      };
    };

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
      settings =
        let
          move_line_up = [
            "extend_to_line_bounds"
            "delete_selection"
            "move_line_up"
            "paste_before"
          ];
          move_line_down = [
            "extend_to_line_bounds"
            "delete_selection"
            "paste_after"
          ];
        in
        {
          keys.normal = {
            "A-up" = move_line_up;
            "A-down" = move_line_down;
            "A-k" = move_line_up;
            "A-j" = move_line_down;
          };
          keys.select = {
            "A-up" = move_line_up;
            "A-down" = move_line_down;
            "A-k" = move_line_up;
            "A-j" = move_line_down;
          };
        };
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

        #helix-gpt # Copilot
        ltex-ls-plus # Spellchecking

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
          ltex = {
            command = "ltex-ls-plus";
            config.ltex = { };
          };
          texlab = {
            command = "texlab";
            config.texlab = {
              build.onSave = true;
              forwardSearch.executable = "${config.programs.zathura.package}/bin/zathura";
              forwardSearch.args = [
                "--synctex-forward"
                "%l:1:%f"
                "%p"
              ];
            };
          };
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
            name = "latex";
            # language-servers = [
            #   { name = "texlab"; }
            #   { name = "ltex"; }
            # ];
            soft-wrap = {
              enable = true;
            };
          }
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

    systemd.user.tmpfiles.rules = [
      "d ${config.home.homeDirectory}/Downloads - - - - -"
    ];

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
        signingKey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        allowedSigners = [
          "git@bulthuis.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKxoQSxfYqf9ITN8Fhckk8WbY4dwtBAXOhC9jxihJvq"
        ];
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
