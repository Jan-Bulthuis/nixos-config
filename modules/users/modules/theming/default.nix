{ pkgs, lib, config, ... }:

with lib;
let
  # Stylix
  stylix = pkgs.fetchFromGitHub {
    owner = "danth";
    repo = "stylix";
    rev = "1ff9d37d27377bfe8994c24a8d6c6c1734ffa116";
    sha256 = "0dz8h1ga8lnfvvmvsf6iqvnbvxrvx3qxi0y8s8b72066mqgvy8y5";
  };
in {
  imports = [
    # Import all themes
    ./themes/gruvbox.nix
    ./themes/catppuccin.nix
  ];

  options.theming =
  let 
    colors = config.theming.schemeColors;
  in  {
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
  };

  config = {
    stylix = {
      enable = true;
      autoEnable = false;

      base16Scheme = config.theming.colorScheme;
      polarity = if config.theming.darkMode then "dark" else "light";
    };
  };
}
