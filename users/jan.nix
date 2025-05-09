# How Jan likes his linux to be configured

{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = (
    lib.recursiveUpdate
      {
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
          bitwarden
          carla
          baobab
          gnome-calculator
          nautilus
        ];

        # desktop.development = "river-light";
        desktop.enable = true;
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
              desktop.theming.background = {
                # path = "unsorted/a_group_of_mountains_with_a_building_in_the_background.jpg";
                # image = "anime/a_colorful_buildings_with_power_lines.jpg";
                image = {
                  url = "https://i.postimg.cc/tTB3dM3T/1382899.png";
                  hash = "sha256-kStcwAtK2vxitU6uaQtZTA5iFS8k0iXkFwinY2M8wQE=";
                };
                # image = {
                #   url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/digital/a_couple_of_people_standing_on_a_mountain.png";
                #   hash = "sha256-SgKG090iSxwOPCGH/2ODPbwe275Zi5k0+d5Hso0mN7c=";
                # };
                themed = true;
                inverted = false;
              };
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
              desktop.theming.background = {
                # path = "unsorted/a_group_of_mountains_with_a_building_in_the_background.jpg";
                # image = "anime/a_cartoon_of_a_street_with_buildings.jpeg";
                image = {
                  url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/digital/a_drawing_of_a_spider_on_a_white_surface.png";
                  hash = "sha256-eCEjM7R9yeHNhZZtvHjrgkfwT25JA7FeMoVwnQ887CQ=";
                };
                themed = true;
                inverted = false;
              };
              desktop.theming.themes.catppuccin = {
                enable = true;
                flavor = lib.mkForce "latte";
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
                  ${pkgs.gnome-session}/bin/gnome-session
                '';
                session = {
                  type = "wayland";
                  desktop = "GNOME";
                };
              };
              modules.river.enable = lib.mkForce false;
              # # Theme configuration
              # desktop.theming =
              #   let
              #     fontpkgs = config.desktop.theming.fonts.pkgs;
              #   in
              #   {
              #     # Fonts
              #     fonts.serif = fontpkgs."DejaVu Serif";
              #     fonts.sansSerif = fontpkgs."Adwaita Sans";
              #     fonts.monospace = fontpkgs."Adwaita Mono";
              #     fonts.emoji = fontpkgs."Noto Color Emoji";
              #     fonts.interface = fontpkgs."Adwaita Sans";
              #     fonts.extraFonts = [ ];

              #     # Color scheme
              #     themes.catppuccin = {
              #       enable = true;
              #       flavor = "mocha";
              #     };
              #   };

              # TODO: Remove everything below, it is here out of convenience and should be elsewhere
              xdg.portal = {
                enable = true;

                config.common.default = [
                  "gnome"
                  "gtk"
                ];

                extraPortals = with pkgs; [
                  xdg-desktop-portal-gnome
                  xdg-desktop-portal-gtk
                ];
              };
              home.packages = [
                # Core utilities
                pkgs.epiphany
                pkgs.gnome-text-editor
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

                # Fonts
                pkgs.cantarell-fonts
                pkgs.dejavu_fonts
                pkgs.source-code-pro # Default monospace font in 3.32
                pkgs.source-sans

                # Other stuff
                pkgs.gnome-session
              ];
            };
          };
        };

        # Pipewire roc sink
        xdg.configFile."pipewire/pipewire.conf.d/60-roc-sink.conf" = {
          text = ''
            context.modules = [
              {
                name = "libpipewire-module-roc-sink"
                args = {
                  fec.code = "rs8m"
                  remote.ip = "10.20.60.251"
                  remote.source.port = 10001
                  remote.repair.port = 10002
                  sink.name = "Roc Sink"
                  sink.props.node.name = "roc-sink"
                }
              }
            ]
          '';
        };

        # Enabled modules
        modules = {
          # Communication
          whatsapp.enable = true;
          discord.enable = true;

          # Browser
          firefox = {
            enable = true;
            default = false;
          };
          qutebrowser = {
            enable = true;
            default = true;
          };

          # Gaming
          steam.enable = true;
          # modrinth.enable = true;
          # es-de.enable = true; # TODO: Fix, again
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
          xpra = {
            enable = true;
            hosts = [
              "mixer@10.20.60.251"
            ];
          };

          # Development
          neovim.enable = true;
          vscode.enable = true;
          docker.enable = true;
          matlab.enable = true;
          mathematica.enable = true;

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
          lib.mkDefault {
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
      }
      {
        # Default desktop environment
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

          config.common.default = lib.mkDefault [
            "wlr"
            "gtk"
          ];

          extraPortals =
            with pkgs;
            lib.mkDefault [
              xdg-desktop-portal-gtk
              xdg-desktop-portal-wlr
            ];
        };

        # Color scheme
        desktop.theming.background = lib.mkDefault {
          # path = "unsorted/a_group_of_mountains_with_a_building_in_the_background.jpg";
          # image = "anime/a_colorful_buildings_with_power_lines.jpg";
          image = {
            url = "https://i.postimg.cc/tTB3dM3T/1382899.png";
            hash = "sha256-kStcwAtK2vxitU6uaQtZTA5iFS8k0iXkFwinY2M8wQE=";
          };
          # image = {
          #   url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/digital/a_couple_of_people_standing_on_a_mountain.png";
          #   hash = "sha256-SgKG090iSxwOPCGH/2ODPbwe275Zi5k0+d5Hso0mN7c=";
          # };
          themed = true;
          inverted = false;
        };
        desktop.theming.themes.catppuccin = {
          enable = true;
          flavor = "mocha";
        };
      }
  );
}
