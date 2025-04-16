{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.desktop.theming;

  # Font module type
  fontModule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Font family name.";
      };
      package = mkOption {
        type = types.anything;
        description = "Font package";
      };
      recommendedSize = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Recommended size for displaying this font.";
      };
      fallbackFonts = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Fallback fonts for specified font.";
      };
    };
  };

  fontModules = [
    # Import all fonts
    ./fonts/cozette-vector.nix
    ./fonts/cozette.nix
    ./fonts/dejavu-sans.nix
    ./fonts/dejavu-serif.nix
    ./fonts/dina.nix
    ./fonts/fira-code.nix
    ./fonts/nerd-fonts-symbols.nix
    ./fonts/noto-color-emoji.nix
    ./fonts/wqy-bitmapsong.nix
    ./fonts/wqy-microhei-mono.nix
    ./fonts/wqy-microhei.nix
    ./fonts/wqy-zenhei-mono.nix
    ./fonts/wqy-zenhei-sharp.nix
    ./fonts/wqy-zenhei.nix
  ];

  # Gather enabled fonts.
  enabledFonts = [
    cfg.fonts.serif.name
    cfg.fonts.sansSerif.name
    cfg.fonts.monospace.name
    cfg.fonts.emoji.name
  ] ++ map (font: font.name) cfg.fonts.extraFonts;

  # Flatten dependencies of fonts
  fontPackages =
    converge
      (
        fonts:
        listToAttrs (
          map
            (font: {
              name = font;
              value = true;
            })
            (
              flatten (map (font: [ font.name ] ++ cfg.fonts.pkgs.${font.name}.fallbackFonts) (attrsToList fonts))
            )
        )
      )
      (
        listToAttrs (
          map (font: {
            name = font;
            value = true;
          }) enabledFonts
        )
      );

  # Convert set of fonts to list of packages
  fontNameList = map (font: font.name) (attrsToList fontPackages);
  fontPackageList = map (font: cfg.fonts.pkgs.${font}.package) fontNameList;
in
{
  imports = [
    ./background.nix

    # Import all themes
    ./themes/catppuccin.nix
    ./themes/gruvbox.nix
    ./themes/oxocarbon.nix
    ./themes/papercolor.nix
    ./themes/sakura.nix
    ./themes/nord.nix
  ];

  options.desktop.theming =
    let
      colors = config.desktop.theming.schemeColors;
    in
    {
      darkMode = mkOption {
        type = types.bool;
        default = false;
        example = true;
        description = "Whether the app should use dark mode.";
      };

      colorScheme = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Base 16 color scheme to use for styling. See stylix documentation for more information.";
      };

      schemeColors = mkOption {
        type = types.attrsOf types.anything;
        default = config.lib.stylix.colors;
        description = "Generated colors from scheme";
      };

      colors = {
        bg = mkOption {
          type = types.str;
          default = colors.base00;
        };
        fg = mkOption {
          type = types.str;
          default = colors.base05;
        };
        bg-status = mkOption {
          type = types.str;
          default = colors.base01;
        };
        fg-status = mkOption {
          type = types.str;
          default = colors.base04;
        };
        bg-selection = mkOption {
          type = types.str;
          default = colors.base02;
        };
        bg-highlight = mkOption {
          type = types.str;
          default = colors.base03;
        };
        fg-search = mkOption {
          type = types.str;
          default = colors.base0A;
        };
        accent = mkOption {
          type = types.str;
          default = colors.base0E;
        };
        border-focused = mkOption {
          type = types.str;
          default = cfg.colors.fg;
        };
        border-unfocused = mkOption {
          type = types.str;
          default = cfg.colors.bg-selection;
        };
      };

      colorsCSS = mkOption {
        type = types.lines;
        default =
          ":root {\n"
          + concatStrings (
            map (color: "  --nix-color-${color.name}: #${color.value};\n") (attrsToList cfg.colors)
          )
          + "}\n\n";
        description = "Colors as css variables";
      };

      layout = {
        borderRadius = mkOption {
          type = types.int;
          default = 0;
          description = "Border radius of windows.";
        };

        borderSize = mkOption {
          type = types.int;
          default = 1;
          description = "Size of borders used throughout UI.";
        };

        windowPadding = mkOption {
          type = types.int;
          default = 2;
          description = "Margin of each window, actual space between windows will be twice this number.";
        };
      };

      fonts = {
        pkgs = mkOption {
          type = types.attrsOf fontModule;
          default = builtins.listToAttrs (
            map (module: {
              name = module.name;
              value = module;
            }) (map (module: (import module) { inherit lib config pkgs; }) fontModules)
          );
          description = "All available font modules.";
        };

        installed = mkOption {
          type = types.listOf types.str;
          default = fontNameList;
          description = "List of installed fonts.";
        };

        serif = mkOption {
          type = fontModule;
          description = "Default serif font";
        };

        sansSerif = mkOption {
          type = fontModule;
          description = "Default sansSerif font.";
        };

        monospace = mkOption {
          type = fontModule;
          description = "Default monospace font.";
        };

        emoji = mkOption {
          type = fontModule;
          description = "Default emoji font.";
        };

        interface = mkOption {
          type = fontModule;
          description = "Default emoji font.";
        };

        extraFonts = mkOption {
          type = types.listOf fontModule;
          default = [ ];
          description = "Additional fonts to install.";
        };
      };
    };

  config = {
    # Enable fontconfig
    modules.fontconfig.enable = true;

    # Install configured fonts
    home.packages = fontPackageList;

    # Configure gnome theme
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = if cfg.darkMode then "prefer-dark" else "prefer-light";
      };
    };

    # Configure qt theme
    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = if cfg.darkMode then "adwaita-dark" else "adwaita-light";
    };

    # Configure gtk theme
    gtk =
      let
        disableCSD = ''
          headerbar.default-decoration {
            margin-bottom: 50px;
            margin-top: -100px;
          }
          window.csd,
          window.csd decoration {
            box-shadow: none;
          }
        '';
      in
      {
        enable = true;

        theme = {
          name = if cfg.darkMode then "Adwaita-dark" else "Adwaita-light";
          package = pkgs.gnome-themes-extra;
        };

        # TODO: Toggles
        gtk3.extraCss = disableCSD;
        gtk4.extraCss = disableCSD;
      };

    # TODO: This should just straight up not be here
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    modules.git.ignores = [
      ".direnv"
    ];

    # TODO: Make cursors configurable using modules.
    home.pointerCursor = {
      gtk.enable = true;
      name = lib.mkForce "BreezeX-RosePine-Linux";
      package = lib.mkForce pkgs.rose-pine-cursor;
      size = lib.mkForce 24;
      x11 = {
        defaultCursor = lib.mkForce "BreezeX-RosePine-Linux";
        enable = true;
      };
    };

    # Enable stylix
    # TODO: Move to own module
    stylix = {
      enable = true;
      autoEnable = false;

      targets = {
        foot.enable = true;
        nixvim.enable = true;
        qutebrowser.enable = true;
        vscode = {
          enable = true;
          profileNames = [ "NixOS" ];
        };
        zathura.enable = true;
      };

      base16Scheme = cfg.colorScheme;
      polarity = if cfg.darkMode then "dark" else "light";

      fonts = {
        serif = getAttrs [
          "name"
          "package"
        ] cfg.fonts.serif;
        sansSerif = getAttrs [
          "name"
          "package"
        ] cfg.fonts.sansSerif;
        monospace = getAttrs [
          "name"
          "package"
        ] cfg.fonts.monospace;
        emoji = getAttrs [
          "name"
          "package"
        ] cfg.fonts.emoji;

        sizes = {
          applications = mkDefault cfg.fonts.serif.recommendedSize;
          desktop = mkDefault cfg.fonts.monospace.recommendedSize; # TODO: See below
          popups = mkDefault cfg.fonts.monospace.recommendedSize; # TODO: Add dedicated UI font
          terminal = mkDefault cfg.fonts.monospace.recommendedSize;
        };
      };
    };
  };
}
