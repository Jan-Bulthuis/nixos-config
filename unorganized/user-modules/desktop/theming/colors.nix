{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.desktop.theming;
in
{
  imports = [
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
        default = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
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
    };

  config = {
    # Configure gnome theme
    dconf.settings = mkIf config.desktop.enable {
      "org/gnome/desktop/interface" = {
        color-scheme = if cfg.darkMode then "prefer-dark" else "prefer-light";
      };
    };

    # Configure qt theme
    qt = mkIf config.desktop.enable {
      enable = true;
      platformTheme.name = "gtk";
      style = {
        name = if cfg.darkMode then "adwaita-dark" else "adwaita-light";
        package = pkgs.adwaita-qt;
      };
    };

    # Configure gtk theme
    gtk = mkIf config.desktop.enable {
      enable = true;
      theme = {
        name = if cfg.darkMode then "Adwaita-dark" else "Adwaita-light";
        package = pkgs.gnome-themes-extra;
      };
    };

    # TODO: This should just straight up not be here
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    modules.git.ignores = [
      ".direnv"
    ];

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
          profileNames = [ "default" ];
        };
        zathura.enable = true;
      };

      base16Scheme = cfg.colorScheme;
      polarity = if cfg.darkMode then "dark" else "light";
    };
  };
}
