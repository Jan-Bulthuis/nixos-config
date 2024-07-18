{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.theming;

  # Stylix
  stylix = pkgs.fetchFromGitHub {
    owner = "danth";
    repo = "stylix";
    rev = "1ff9d37d27377bfe8994c24a8d6c6c1734ffa116";
    sha256 = "0dz8h1ga8lnfvvmvsf6iqvnbvxrvx3qxi0y8s8b72066mqgvy8y5";
  };

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
        default = [];
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
  fontPackages = converge (fonts:
    listToAttrs (map (font: {
      name = font;
      value = true;
    }) (
      flatten (map (font: 
        [ font.name ]
        ++ cfg.fonts.pkgs.${font.name}.fallbackFonts
      ) (attrsToList fonts))
    ))
  ) (listToAttrs (map (font: {
    name = font;
    value = true;
  }) enabledFonts));

  # Convert set of fonts to list of packages
  fontNameList = map (font: font.name) (attrsToList fontPackages);
  fontPackageList = map (font: cfg.fonts.pkgs.${font}.package) fontNameList;
in {
  imports = [
    # Import all themes
    ./themes/gruvbox.nix
    ./themes/catppuccin.nix
  ];

  options.modules.theming.enable = mkEnableOption "theming";

  options.theming = let colors = config.theming.schemeColors; in {
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
      accent = mkOption {
        type = types.str;
        default = colors.base09;
      };
      focused = mkOption {
        type = types.str;
        default = cfg.colors.fg;
      };
      unfocused = mkOption {
        type = types.str;
        default = colors.base02;
      };
      alert = mkOption {
        type = types.str;
        default = "ffffff"; # TODO: Derive color from theme
      };
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
        default = builtins.listToAttrs (map (module: {
          name = module.name;
          value = module;
        }) (map (module: (import module) { inherit lib config pkgs; }) fontModules));
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

      extraFonts = mkOption {
        type = types.listOf fontModule;
        default = [];
        description = "Additional fonts to install.";
      };
    };
  };

  config = mkIf config.modules.theming.enable {
    # Enable fontconfig
    modules.fontconfig.enable = true;

    # Install configured fonts
    home.packages = fontPackageList;

    # Enable stylix
    # TODO: Move to own module
    stylix = {
      enable = true;
      autoEnable = false;

      targets = {
        vscode.enable = config.modules.vscode.enable;
      };

      base16Scheme = cfg.colorScheme;
      polarity = if cfg.darkMode then "dark" else "light";

      fonts = {
        serif = getAttrs [ "name" "package" ] cfg.fonts.serif;
        sansSerif = getAttrs [ "name" "package" ] cfg.fonts.sansSerif;
        monospace = getAttrs [ "name" "package" ] cfg.fonts.monospace;
        emoji = getAttrs [ "name" "package" ] cfg.fonts.emoji;

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
