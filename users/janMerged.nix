{ lib, pkgs, config, ... }:

let
  # Theming constants
  colors = config.lib.stylix.colors;
  fonts = config.stylix.fonts;
  borderSize = 1;
  windowPadding = 2;

  waylockOptions = "-init-color 0x${colors.base00} -input-color 0x${colors.base02} -fail-color 0x${colors.base00}";
in {
  # Extra modules
  imports = [
    # nixvim.homeManagerModules.nixvim
    # stylix.homeManagerModules.stylix
  ];

  # Packages
  home.packages = with pkgs; [
    # Programs
    # vscode
    # feishin
    # discord
    # obsidian
    # winbox

    # Utilities
    pulsemixer
    # waylock
    playerctl

    # Fish plugin dependencies
    # grc
    # fzf

    # Rust development
    # rustc
    # cargo
    # rustfmt

    # Bitwarden
    # rofi-rbw

    # LaTeX libraries
    # (pkgs.texlive.combine {
    #   inherit (pkgs.texlive) scheme-full;
    # })
  ];

  # Stylix
  stylix = {
    # enable = true;
    # polarity = "dark";

    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # fonts = {
    #   # monospace = {
    #   #   package = pkgs.dina-font;
    #   #   name = "Dina";
    #   # };

    #   sizes = {
    #     terminal = 9;
    #   };
    # };

    # autoEnable = false;
    # targets = {
    #   foot.enable = true;
    #   nixvim.enable = true;
    #   qutebrowser.enable = true;
    #   vscode.enable = true;
    #   # zathura.enable = true;
    # };
  };

  # Fish shell
  # programs.fish = {
  #   enable = true;

  #   plugins = [
  #     { name = "done"; src = pkgs.fishPlugins.done.src; }
  #     { name = "fzf"; src = pkgs.fishPlugins.fzf-fish.src; }
  #     { name = "grc"; src = pkgs.fishPlugins.grc.src; }
  #   ];
  # };

  # # Bash prompt
  # programs.bash = {
  #   enable = true;
  #   initExtra = ''
  #     if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
  #     then
  #       shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
  #       exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
  #       fi
  #   '';
  #   bashrcExtra = ''
  #     FG_BLACK="\[$(tput setaf 0)\]"
  #     FG_RED="\[$(tput setaf 1)\]"
  #     FG_GREEN="\[$(tput setaf 2)\]"
  #     FG_YELLOW="\[$(tput setaf 3)\]"
  #     FG_BLUE="\[$(tput setaf 4)\]"
  #     FG_MAGENTA="\[$(tput setaf 5)\]"
  #     FG_CYAN="\[$(tput setaf 6)\]"
  #     FG_WHITE="\[$(tput setaf 7)\]"

  #     RESET="\[$(tput sgr0)\]"

  #     export PS0="\n''${RESET}"
  #     export PS1="''${FG_GREEN}\n│\w\n│"
  #     export PS2="│"
  #   '';
  # };

  # Direnv setup
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Qutebrowser
  programs.qutebrowser = {
    enable = true;

    extraConfig = ''
    config.set("colors.webpage.darkmode.enabled", False)
    config.set("colors.webpage.preferred_color_scheme", "dark")
    config.set("fonts.default_family", "${fonts.monospace.name}")
    config.set("fonts.default_size", "${toString fonts.sizes.terminal}pt")
    '';
  };

  # Bitwarden client
  # programs.rbw = {
  #   enable = true;
  #   settings = {
  #     base_url = "https://keys.bulthuis.dev";
  #     identity_url = "https://keys.bulthuis.dev";
  #     email = "jan@bulthuis.dev";
  #     pinentry = pkgs.pinentry;
  #   };
  # };

  # Firefox
  # programs.firefox = {
  #   enable = true;
  #   policies = {
  #     AppAutoUpdate = false;
  #     BlockAboutAddons = true;
  #     BlockAboutConfig = true;
  #     BlockAboutProfiles = true;
  #     DisableAppUpdate = true;
  #     DisableFeedbackCommands = true;
  #     DisableMasterPasswordCreation = true;
  #     DisablePocket = true;
  #     DisableProfileImport = true;
  #     DisableProfileRefresh = true;
  #     DisableSetDesktopBackground = true;
  #     DisableTelemetry = true;
  #     DisplayBookmarksToolbar = "never";
  #     DisplayMenuBar = "never";
  #     DNSOverHTTPS = { Enabled = false; };
  #     DontCheckDefaultBrowser = true;
  #     PasswordManagerEnabled = false;
  #     TranslateEnabled = true;
  #     UseSystemPrintDialog = true;
  #   };
  #   profiles.nixos = {
  #     search.default = "DuckDuckGo";

  #     extensions = with pkgs.nur.repos.rycee.firefox-addons; [
  #       ublock-origin
  #     ];

  #     settings = {
  #       "browser.tabs.inTitlebar" = 0;
  #       "extensions.autoDisableScopes" = 0;
  #     };

  #     # Force overwriting configuration file
  #     search.force = true;
  #     containersForce = true;
  #   };
  # };

  # # Email setup
  # accounts.email.accounts = {
  #   Personal = {
  #     primary = true;
  #     realName = "Jan Bulthuis";
  #     userName = "jan@bulthuis.dev";
  #     address = "jan@bulthuis.dev";
  #     thunderbird.enable = true;

  #     flavor = "plain";
  #     imap = {
  #       host = "mail.bulthuis.dev";
  #       port = 993;
  #     };
  #     smtp = {
  #       host = "mail.bulthuis.dev";
  #       port = 465;
  #     };
  #   };
  # };

  # # Thunderbird setup
  # programs.thunderbird = {
  #   enable = true;
  #   profiles.nixos = {
  #     isDefault = true;
  #   };
  # };

  # Rofi setup
  # programs.rofi = {
  #   enable = true;
  #   package = pkgs.rofi-wayland;
  #   font = "${fonts.monospace.name} ${toString fonts.sizes.terminal}";
  #   theme = let
  #     inherit (config.lib.formats.rasi) mkLiteral;
  #   in {
  #     "*" = {
  #       background-color = mkLiteral "rgba(0, 0, 0, 0%)";
  #       border-color = mkLiteral colors.withHashtag.base05;
  #       text-color = mkLiteral colors.withHashtag.base05;
  #     };
  #     mainbox = {
  #       background-color = mkLiteral colors.withHashtag.base00;
  #       border = mkLiteral "${toString borderSize}px";
  #     };
  #     element-text = {
  #       highlight = mkLiteral colors.withHashtag.base09;
  #     };
  #     inputbar = {
  #       children = mkLiteral "[textbox-search, entry]";
  #     };
  #     listview = {
  #       padding = mkLiteral "2px 0px";
  #     };
  #     textbox-search = {
  #       expand = false;
  #       content = "> ";
  #     };
  #     "inputbar, message" = {
  #       padding = mkLiteral "2px";
  #     };
  #     element = {
  #       padding = mkLiteral "0px 2px";
  #     };
  #     "element selected" = {
  #       background-color = mkLiteral colors.withHashtag.base02;
  #     };
  #   };
  # };

  # Dark mode
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
  # systemd.user.sessionVariables = config.home.sessionVariables;

  # Configure GTK
  # gtk = let
  #   css = ''
  #     headerbar.default-decoration {
  #       margin-bottom: 50px;
  #       margin-top: -100px;
  #     }

  #     window.csd,
  #     window.csd decoration {
  #       box-shadow: none;
  #     }
  #   '';
  # in {
  #   enable = true;

  #   # Dark mode
  #   theme = {
  #    name = "Adwaita-dark";
  #    package = pkgs.gnome-themes-extra;
  #   };

  #   # Disable CSD
  #   gtk3.extraCss = css;
  #   gtk4.extraCss = css;
  # };

  # Cursors
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

  # Neovim setup
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
    ];

    opts = {
      number = true;
      relativenumber = true;

      signcolumn = "yes";

      ignorecase = true;
      smartcase = true;

      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 0;
      expandtab = true;
      smarttab = true;

      list = true;
      listchars = "tab:»┈«,trail:·,extends:→,precedes:←,nbsp:␣";
    };

    diagnostics = {
      enable = true;
      signs = true;
      underline = true;
      update_in_insert = true;
    };

    extraConfigLua = ''
      vim.fn.sign_define("DiagnosticSignError",
        {text = "", texthl = "DiagnosticSignError"})
      vim.fn.sign_define("DiagnosticSignWarn",
        {text = "", texthl = "DiagnosticSignWarn"})
      vim.fn.sign_define("DiagnosticSignInfo",
        {text = "", texthl = "DiagnosticSignInfo"})
      vim.fn.sign_define("DiagnosticSignHint",
        {text = "💡", texthl = "DiagnosticSignHint"})
    '';

    keymaps = [
      # Save shortcut
      {
        action = ":update<CR>";
        key = "<C-s>";
        mode = "n";
      }
      {
        action = "<C-o>:update<CR>";
        key = "<C-s>";
        mode = "i";
      }

      # Neo tree
      {
        action = ":Neotree action=focus reveal toggle<CR>";
        key = "<leader>n";
        mode = "n";
        options.silent = true;
      }
    ];

    autoCmd = [
      {
        desc = "Automatic formatting";
        event = "BufWritePre";
        callback = {
          __raw = ''
            function()
              vim.lsp.buf.format {
                async = false,
              }
            end
          '';
        };
      }
    ];

    highlight = {
      Comment = {
        italic = true;
        fg = colors.withHashtag.base03;
      };

    };

    plugins.lsp = {
      enable = true;
    };

    #plugins.treesitter = {
    #  enable = true;
    #};

    plugins.cmp = {
      enable = true;

      settings = {
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
        sources = [
          { name = "path"; }
          { name = "nvim_lsp"; }
        ];
      };
    };

    plugins.neo-tree = {
      enable = true;

      closeIfLastWindow = true;
      window = {
        width = 30;
        autoExpandWidth = true;
      };

      extraOptions = {
        default_component_configs.git_status.symbols = {
          # Change type
          added = "+";
          deleted = "✕";
          modified = "✦";
          renamed = "→";

          # Status type
          untracked = "?";
          ignored = "▫";
          unstaged = "□";
          staged = "■";
          conflict = "‼";
        };
      };
    };

    #plugins.cmp-nvim-lsp.enable = true;

    plugins.gitsigns = {
      enable = true;
      settings.current_line_blame = true;
    };

    #plugins.copilot-vim = {
    #  enable = true;
    #};

    plugins.rust-tools = {
      enable = true;
    };

    plugins.vimtex = {
      enable = true;
      texlivePackage = null;
      settings = {
        view_method = "zathura";
      };
    };
  };
  programs.neovim.defaultEditor = true;

  # Foot setup
  # programs.foot = {
  #   enable = true;
  #   settings = {
  #     main = let
  #       font = fonts.monospace.name;
  #       size = toString fonts.sizes.terminal;
  #     in {
  #       font = lib.mkForce "${font}:style=Regular:size=${size}";
  #       font-bold = "${font}:style=Bold:size=${size}";
  #       font-italic = "${font}:style=Italic:size=${size}";
  #       font-bold-italic = "${font}:style=Bold Italic:size=${size}";
  #     };
  #   };
  # };

  # Fuzzel setup
  #programs.fuzzel = {
  #  enable = true;
  #  settings = {
  #    main = {
  #      font = "${fonts.monospace.name}:size=${toString fonts.sizes.terminal}";
#          icons-enabled = "no";
#          horizontal-pad = borderSize;
#          vertical-pad = borderSize;
#          inner-pad = 2;
#          dpi-aware = "no";
#        };
#        colors = {
#          background = colors.base00 + "ff";
#          text = colors.base05 + "ff";
#          match = colors.base09 + "ff";
#          selection = colors.base02 + "ff";
#          selection-text = colors.base05 + "ff";
#          selection-match = colors.base09 + "ff";
#          border = colors.base05 + "ff";
#        };
#        border = {
#          width = borderSize;
#          radius = 0;
#        };
#      };
#    };

  # Mako notifications setup
  # services.mako = {
  #   enable = true;
  #   anchor = "top-right";
  #   defaultTimeout = 5000;
  #   backgroundColor = "#${colors.base00}ff";
  #   textColor = "#${colors.base05}ff";
  #   borderColor = "#${colors.base05}ff";
  #   progressColor = "#${colors.base09}ff";
  #   borderRadius = 0;
  #   borderSize = borderSize;
  #   font = "${fonts.monospace.name} ${toString fonts.sizes.terminal}";
  # };

  # Waybar setup
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        spacing = 16;
        modules-left = [
          "river/tags"
        ];
        modules-center = [
          #"river/window"
          "mpris"
        ];
        modules-right = [
          "pulseaudio"
          "battery"
          "clock"
        ];
        "river/window" = {
          max-length = 50;
        };
        "river/tags" = {
          tag-labels = [
            "一"
            "二"
            "三"
            "四"
            "五"
            "六"
            "七"
            "八"
            "九"
          ];
          disable-click = false;
        };
        pulseaudio = {
          tooltip = false;
          format = "{icon}   {volume}%"; # Spacing achieved using "Thin Space"
          #format-muted = "";
          format-muted = "{icon}  --%"; # Spacing achieved using "Thin Space"
          format-icons = {
            #headphone = "";
            #default = [ "" "" ];
            headphone = "";
            headphone-muted = "";
            default = [ "" "" "" ];
          };
        };
        battery = {
          format = "{icon} {capacity}%"; # Spacing achieved using "Thin Space"
          format-charging = " {capacity}%"; # Spacing achieved using "Thin Space"
          #format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format-icons = [ "" "" "" "" "" "" "" "" "" "" "" ];
          interval = 1;
        };
        clock = {
          #format = "󰅐 {:%H:%M}";
          #format = "   {:%H:%M}"; # Spacing achieved using "Thin Space"
          format = "{:%H:%M}";
        };
        mpris = {
          format = "{dynamic}";
          tooltip-format = "";
          interval = 1;
        };
      };
    };
    style = ''
      window#waybar {
        color: #${colors.base05};
        background-color: #${colors.base00};
        border-style: none none solid none;
        border-width: ${toString borderSize}px;
        border-color: #${colors.base01};
        font-size: 12px;
        font-family: "${fonts.monospace.name}";
      }

      .modules-right {
        margin: 0 8px 0 0;
      }

      #tags button {
        color: #${colors.base03};
        padding: 0 5px 1px 5px;
        border-radius: 0;
        font-size: 16px;
        font-family: "Unifont";
      }

      #tags button.occupied {
        color: #${colors.base05};
      }

      #tags button.focused {
        color: #${colors.base09};
      }

      #tags.button.bell {
        color: #${colors.base0A};
      }
    '';
  };

  # home.stateVersion = "24.05";
}
