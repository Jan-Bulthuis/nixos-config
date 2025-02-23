# How Jan likes his linux to be configured

{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = {
    # State version
    home.stateVersion = "24.05";

    # TODO: Move into modules
    home.packages = with pkgs; [
      libreoffice-still
      remmina
      pinentry
      thunderbird
      signal-desktop
      prusa-slicer
      freecad-wayland
      inkscape
      ente-auth
    ];

    desktop.environments = {
      river-dark = {
        name = "River Dark";
        type = "custom";
        config = { };
        extraConfig = {
          modules = {
            # Desktop environment
            river.enable = true;
            waylock.enable = true;
            waybar.enable = true;
            mako.enable = true;
            foot.enable = true;
            rofi-rbw.enable = true;
          };

          # TODO: Remove everything below, it is here out of convenience and should be elsewhere
          xdg.portal = {
            enable = true;

            config.common.default = [
              "wlr"
              "gtk"
            ];

            extraPortals = with pkgs; [
              xdg-desktop-portal-gtk
              xdg-desktop-portal-wlr
            ];
          };

          # Color scheme
          desktop.theming.themes.catppuccin = {
            enable = true;
            flavor = "mocha";
          };
        };
      };
      river-light = {
        name = "River Light";
        type = "custom";
        config = { };
        extraConfig = {
          modules = {
            # Desktop environment
            river.enable = true;
            waylock.enable = true;
            waybar.enable = true;
            mako.enable = true;
            foot.enable = true;
            rofi-rbw.enable = true;
          };

          # TODO: Remove everything below, it is here out of convenience and should be elsewhere
          xdg.portal = {
            enable = true;

            config.common.default = [
              "wlr"
              "gtk"
            ];

            extraPortals = with pkgs; [
              xdg-desktop-portal-gtk
              xdg-desktop-portal-wlr
            ];
          };

          # Color scheme
          desktop.theming.themes.catppuccin = {
            enable = true;
            flavor = lib.mkForce "latte";
          };
        };
      };
      cosmic = {
        name = "Cosmic";
        type = "custom";
        config = { };
        extraConfig = {
          desktop = {
            initScript = ''
              ${pkgs.dbus}/bin/dbus-run-session ${pkgs.cosmic-session}/bin/cosmic-session
            '';
            session = {
              type = "wayland";
              desktop = "cosmic";
            };
          };
          home.packages = with pkgs; [
            adwaita-icon-theme
            alsa-utils
            cosmic-applets
            cosmic-applibrary
            cosmic-bg
            (cosmic-comp.override {
              useXWayland = false;
            })
            cosmic-edit
            cosmic-files
            cosmic-greeter
            cosmic-icons
            cosmic-idle
            cosmic-launcher
            cosmic-notifications
            cosmic-osd
            cosmic-panel
            cosmic-player
            cosmic-randr
            cosmic-screenshot
            cosmic-session
            cosmic-settings
            cosmic-settings-daemon
            cosmic-term
            cosmic-wallpapers
            cosmic-workspaces-epoch
            hicolor-icon-theme
            playerctl
            pop-icon-theme
            pop-launcher
            xdg-user-dirs
            xwayland
            cosmic-store

            # Fonts
            fira
            noto-fonts
            open-sans
          ];

          xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
              xdg-desktop-portal-cosmic
              xdg-desktop-portal-gtk
            ];
            configPackages = lib.mkDefault (with pkgs; [ xdg-desktop-portal-cosmic ]);
          };

        };
      };
      gnome = {
        name = "Gnome";
        type = "custom";
        config = { };
        extraConfig = {
          programs = {
            gnome-shell.enable = true;
          };
          desktop = {
            initScript = ''
              ${pkgs.dbus}/bin/dbus-run-session ${pkgs.gnome-session}/bin/gnome-session
            '';
            session = {
              type = "wayland";
              desktop = "GNOME";
            };
          };
          home.packages = [
            # Core utilities
            pkgs.baobab
            pkgs.epiphany
            pkgs.gnome-text-editor
            pkgs.gnome-calculator
            pkgs.gnome-calendar
            pkgs.gnome-characters
            pkgs.gnome-clocks
            pkgs.gnome-console
            pkgs.gnome-contacts
            pkgs.gnome-font-viewer
            pkgs.gnome-logs
            pkgs.gnome-maps
            pkgs.gnome-music
            pkgs.gnome-system-monitor
            pkgs.gnome-weather
            pkgs.loupe
            pkgs.nautilus
            pkgs.gnome-connections
            pkgs.simple-scan
            pkgs.snapshot
            pkgs.totem
            pkgs.yelp

            # Optional packages
            pkgs.adwaita-icon-theme
            pkgs.gnome-backgrounds
            pkgs.gnome-bluetooth
            pkgs.gnome-color-manager
            pkgs.gnome-control-center
            pkgs.gnome-shell-extensions
            pkgs.gnome-tour # GNOME Shell detects the .desktop file on first log-in.
            pkgs.gnome-user-docs
            pkgs.glib # for gsettings program
            pkgs.gnome-menus
            pkgs.gtk3.out # for gtk-launch program
            pkgs.xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
            pkgs.xdg-user-dirs-gtk # Used to create the default bookmarks

            # Games
            pkgs.aisleriot
            pkgs.atomix
            pkgs.five-or-more
            pkgs.four-in-a-row
            pkgs.gnome-2048
            pkgs.gnome-chess
            pkgs.gnome-klotski
            pkgs.gnome-mahjongg
            pkgs.gnome-mines
            pkgs.gnome-nibbles
            pkgs.gnome-robots
            pkgs.gnome-sudoku
            pkgs.gnome-taquin
            pkgs.gnome-tetravex
            pkgs.hitori
            pkgs.iagno
            pkgs.lightsoff
            pkgs.quadrapassel
            pkgs.swell-foop
            pkgs.tali

            # Fonts
            pkgs.cantarell-fonts
            pkgs.dejavu_fonts
            pkgs.source-code-pro # Default monospace font in 3.32
            pkgs.source-sans

            # Other stuff
            pkgs.gnome-session
            # pkgs.gnome-session.sessions
          ];
        };
      };
    };

    # Desktop environments
    # desktop.environments =
    #   let
    #   in
    #   [
    #     {
    #       name = "river";
    #       type = "custom";
    #       config = { };
    #       extraConfig = {
    #         home.packages = with pkgs; [ cowsay ];
    #       };
    #     }
    #   ];

    # Enabled modules
    modules = {
      # Communication
      whatsapp.enable = true;
      discord.enable = true;

      # Browser
      firefox = {
        enable = true;
        default = true;
      };
      qutebrowser = {
        enable = true;
        default = false;
      };

      # Gaming
      steam.enable = true;
      modrinth.enable = true;
      es-de.enable = true;
      retroarch.enable = true;
      ryujinx.enable = true;

      # Media
      spotify.enable = true;
      feishin.enable = true;

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
      btop.enable = true;
      fish.enable = true;
      bluetuith.enable = false;
      winbox.enable = true;
      obsidian.enable = true;
      zathura.enable = true;
      eduvpn.enable = true;
      keyring.enable = true;
      scripts.enable = true;

      # Development
      neovim.enable = true;
      vscode.enable = true;
      docker.enable = true;
      matlab.enable = true;
      mathematica.enable = false;

      # Languages
      haskell.enable = false;
      js.enable = true;
      nix.enable = true;
      rust.enable = true;
      python.enable = true;
      cpp.enable = true;
      tex.enable = true;
      jupyter.enable = true;

      # Enable unfree
      unfree.enable = true;
    };

    # Theme configuration
    desktop.theming =
      let
        fontpkgs = config.desktop.theming.fonts.pkgs;
      in
      {
        # Fonts
        fonts.serif = fontpkgs."DejaVu Serif";
        fonts.sansSerif = fontpkgs."DejaVu Sans";
        fonts.monospace = fontpkgs."Dina";
        fonts.emoji = fontpkgs."Noto Color Emoji";
        fonts.interface = fontpkgs."Dina";
        fonts.extraFonts = [ ];

        # Color scheme
        themes.catppuccin = {
          enable = true;
          flavor = "mocha";
        };
      };

    # TODO: Remove everything below, it is here out of convenience and should be elsewhere
    xdg.portal = {
      enable = true;

      config.common.default = [
        "wlr"
        "gtk"
      ];

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };

  };
}
