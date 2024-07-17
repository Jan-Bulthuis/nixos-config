# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
  });
  stylix = import (pkgs.fetchFromGitHub {
    owner = "danth";
    repo = "stylix";
    rev = "1ff9d37d27377bfe8994c24a8d6c6c1734ffa116";
    sha256 = "0dz8h1ga8lnfvvmvsf6iqvnbvxrvx3qxi0y8s8b72066mqgvy8y5";
  });

  fontInstallPhase = ''
    runHook preInstall

    install -Dm644 *.ttc -t $out/share/fonts/

    runHook postInstall
  '';

  my-wqy-zenhei = pkgs.stdenv.mkDerivation rec {
    pname = "wqy-zenhei";
    version = "0.9.45";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/wqy/${pname}-${version}.tar.gz";
      hash = "sha256-5LfjBkdb+UJ9F1dXjw5FKJMMhMROqj8WfUxC8RDuddY=";
    };

    installPhase = fontInstallPhase;
  };

  my-wqy-microhei = pkgs.stdenv.mkDerivation rec {
    pname = "wqy-microhei";
    version = "0.2.0-beta";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/wqy/${pname}-${version}.tar.gz";
      hash = "sha256-KAKsgCOqNqZupudEWFTjoHjTd///QhaTQb0jeHH3IT4=";
    };

    installPhase = fontInstallPhase;
  };

  my-wqy-bitmapsong = pkgs.stdenv.mkDerivation rec {
    pname = "wqy-bitmapsong-pcf";
    version = "1.0.0-RC1";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/wqy/${pname}-${version}.tar.gz";
      #hash = "sha256-r2Vf7ftJCqu7jOc2AqCKaoR/r8eNw2P/OQGqbDOEyl0=";
      hash = "sha256-0uvwkRUbvJ0remTnlP8dElRjaBVd6iukNYBTE/CTO7s=";
    };

    buildInputs = [ pkgs.fontforge ];
    buildPhase = ''
      newName() {
        test "''${1:5:1}" = i && _it=Italic || _it=
        case ''${1:6:3} in
          400) test -z $it && _weight=Medium ;;
          700) _weight=Bold ;;
        esac
        _pt=''${1%.pcf}
        _pt=''${_pt#*-}
        echo "WenQuanYi_Bitmap_Song$_weight$_it$_pt"
      }

      for i in *.pcf; do
        fontforge -lang=ff -c "Open(\"$i\"); Generate(\"$(newName $i).otb\")"
      done
    '';
    installPhase = ''
      install -Dm644 *.otb -t $out/share/fonts/
    '';
  };
in {
  imports =
    [
      # Include home manager
      <home-manager/nixos>
    ];

  # Enable NUR
  nixpkgs.config.packageOverrides = pkgs: {
    # TODO: Pin the version
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    tmp.cleanOnBoot = true;

    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.checkJournalingFS = false;

    plymouth = {
      enable = false;
      theme = "text";
    };

    kernelParams = [
      "quiet"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "video=efifb:nobgrt"
      "bgrt_disable"
    ];
  };

  # Set up console
  console = {
    keyMap = "us";
  };

  # Set up networking
  networking.wireless.userControlled.enable = true;
  networking.hostName = "20212060"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.allowAuxiliaryImperativeNetworks = true;  

  # Set up graphics
  hardware.graphics.enable32Bit = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  # Set up tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Set time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Set up input
  services.libinput.enable = true;

  # Display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --greeting \"Hewwo! >_< :3\" --time --cmd river --asterisks";
        user = "greeter";
      };
    };
  };

  # PAM setup
  security.pam.services.waylock = {};

  # Enable programs
  programs.river.enable = true;

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };

  # Gamer moment
  programs.steam.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jan = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  home-manager.backupFileExtension = "bak";
  home-manager.users.jan = let
    # Theming constants
    colors = config.home-manager.users.jan.lib.stylix.colors;
    fonts = config.home-manager.users.jan.stylix.fonts;
    borderSize = 1;
    windowPadding = 2;

    waylockOptions = "-init-color 0x${colors.base00} -input-color 0x${colors.base02} -fail-color 0x${colors.base00}";
  in {
    # Extra modules
    imports = [
      nixvim.homeManagerModules.nixvim
      stylix.homeManagerModules.stylix
    ];

    # Packages
    home.packages = with pkgs; [
      # Programs
      vscode
      feishin
      discord
      obsidian
      winbox

      # Utilities
      pulsemixer
      wl-clipboard
      pinentry-rofi
      wtype
      waylock
      playerctl

      # Fish plugin dependencies
      grc
      fzf

      # Rust development
      rustc
      cargo
      rustfmt

      # Bitwarden
      rofi-rbw

      # LaTeX libraries
      (pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-full;
      })
    ];

    # Allow unfree
    nixpkgs.config.allowUnfree = false;

    # Stylix
    stylix = {
      enable = true;
      polarity = "dark";

      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
      fonts = {
        monospace = {
          package = pkgs.dina-font;
          name = "Dina";
        };

        sizes = {
          terminal = 9;
        };
      };

      autoEnable = false;
      targets = {
        foot.enable = true;
        nixvim.enable = true;
        qutebrowser.enable = true;
        vscode.enable = true;
        zathura.enable = true;
      };
    };

    # Fish shell
    programs.fish = {
      enable = true;

      plugins = [
        { name = "done"; src = pkgs.fishPlugins.done.src; }
        { name = "fzf"; src = pkgs.fishPlugins.fzf-fish.src; }
        { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      ];
    };

    # Bash prompt
    programs.bash = {
      enable = true;
      initExtra = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
      '';
      bashrcExtra = ''
        FG_BLACK="\[$(tput setaf 0)\]"
        FG_RED="\[$(tput setaf 1)\]"
        FG_GREEN="\[$(tput setaf 2)\]"
        FG_YELLOW="\[$(tput setaf 3)\]"
        FG_BLUE="\[$(tput setaf 4)\]"
        FG_MAGENTA="\[$(tput setaf 5)\]"
        FG_CYAN="\[$(tput setaf 6)\]"
        FG_WHITE="\[$(tput setaf 7)\]"

        RESET="\[$(tput sgr0)\]"

        export PS0="\n''${RESET}"
        export PS1="''${FG_GREEN}\n│\w\n│"
        export PS2="│"
      '';
    };

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
    programs.rbw = {
      enable = true;
      settings = {
        base_url = "https://keys.bulthuis.dev";
        identity_url = "https://keys.bulthuis.dev";
        email = "jan@bulthuis.dev";
        pinentry = pkgs.pinentry;
      };
    };

    # Firefox
    programs.firefox = {
      enable = true;
      policies = {
        AppAutoUpdate = false;
        BlockAboutAddons = true;
        BlockAboutConfig = true;
        BlockAboutProfiles = true;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableMasterPasswordCreation = true;
        DisablePocket = true;
        DisableProfileImport = true;
        DisableProfileRefresh = true;
        DisableSetDesktopBackground = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "never";
        DNSOverHTTPS = { Enabled = false; };
        DontCheckDefaultBrowser = true;
        PasswordManagerEnabled = false;
        TranslateEnabled = true;
        UseSystemPrintDialog = true;
      };
      profiles.nixos = {
        search.default = "DuckDuckGo";

        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
        ];

        settings = {
          "browser.tabs.inTitlebar" = 0;
          "extensions.autoDisableScopes" = 0;
        };

        # Force overwriting configuration file
        search.force = true;
        containersForce = true;
      };
    };

    # Email setup
    accounts.email.accounts = {
      Personal = {
        primary = true;
        realName = "Jan Bulthuis";
        userName = "jan@bulthuis.dev";
        address = "jan@bulthuis.dev";
        thunderbird.enable = true;

        flavor = "plain";
        imap = {
          host = "mail.bulthuis.dev";
          port = 993;
        };
        smtp = {
          host = "mail.bulthuis.dev";
          port = 465;
        };
      };
    };

    # Thunderbird setup
    programs.thunderbird = {
      enable = true;
      profiles.nixos = {
        isDefault = true;
      };
    };

    # Rofi setup
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "${fonts.monospace.name} ${toString fonts.sizes.terminal}";
      theme = let
        inherit (config.home-manager.users.jan.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
	  background-color = mkLiteral "rgba(0, 0, 0, 0%)";
	  border-color = mkLiteral colors.withHashtag.base05;
	  text-color = mkLiteral colors.withHashtag.base05;
	};
	mainbox = {
	  background-color = mkLiteral colors.withHashtag.base00;
	  border = mkLiteral "${toString borderSize}px";
	};
	element-text = {
          highlight = mkLiteral colors.withHashtag.base09;
	};
	inputbar = {
          children = mkLiteral "[textbox-search, entry]";
	};
	listview = {
	  padding = mkLiteral "2px 0px";
	};
	textbox-search = {
	  expand = false;
	  content = "> ";
	};
        "inputbar, message" = {
          padding = mkLiteral "2px";
	};
	element = {
          padding = mkLiteral "0px 2px";
	};
	"element selected" = {
	  background-color = mkLiteral colors.withHashtag.base02;
	};
      };
    };

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
    systemd.user.sessionVariables = config.home-manager.users.jan.home.sessionVariables;

    # Configure GTK
    gtk = let
      css = ''
        headerbar.default-decoration {
          margin-bottom: 50px;
	  margin-top: -100px;
	}

	window.csd,
	window.csd decoration {
          box-shadow: none;
	}
      '';
    in {
      enable = true;

      # Dark mode
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };

      # Disable CSD
      gtk3.extraCss = css;
      gtk4.extraCss = css;
    };

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
    programs.foot = {
      enable = true;
      settings = {
        main = let
          font = fonts.monospace.name;
          size = toString fonts.sizes.terminal;
        in {
          font = lib.mkForce "${font}:style=Regular:size=${size}";
          font-bold = "${font}:style=Bold:size=${size}";
          font-italic = "${font}:style=Italic:size=${size}";
          font-bold-italic = "${font}:style=Bold Italic:size=${size}";
        };
      };
    };

    # Fuzzel setup
    #programs.fuzzel = {
    #  enable = true;
    #  settings = {
    #    main = {
    #      font = "${fonts.monospace.name}:size=${toString fonts.sizes.terminal}";
#	  icons-enabled = "no";
#	  horizontal-pad = borderSize;
#	  vertical-pad = borderSize;
#	  inner-pad = 2;
#	  dpi-aware = "no";
#        };
#	colors = {
#          background = colors.base00 + "ff";
#	  text = colors.base05 + "ff";
#	  match = colors.base09 + "ff";
#	  selection = colors.base02 + "ff";
#	  selection-text = colors.base05 + "ff";
#	  selection-match = colors.base09 + "ff";
#	  border = colors.base05 + "ff";
#	};
#	border = {
#          width = borderSize;
#	  radius = 0;
#	};
#      };
#    };

    # Mako notifications setup
    services.mako = {
      enable = true;
      anchor = "top-right";
      defaultTimeout = 5000;
      backgroundColor = "#${colors.base00}ff";
      textColor = "#${colors.base05}ff";
      borderColor = "#${colors.base05}ff";
      progressColor = "#${colors.base09}ff";
      borderRadius = 0;
      borderSize = borderSize;
      font = "${fonts.monospace.name} ${toString fonts.sizes.terminal}";
    };

    # Waybar setup
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
      };
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

    # River setup
    wayland.windowManager.river = {
      enable = true;
      xwayland.enable = true;
      settings = let
        layout = "rivertile";
	layoutOptions = "-outer-padding ${toString windowPadding} -view-padding ${toString windowPadding}";
        modes = ["normal" "locked"];
	tags = [1 2 3 4 5 6 7 8 9];

        # Quick pow function
	pow2 = power:
	  if power != 0
	  then 2 * (pow2 (power - 1))
	  else 1;

	# Modifiers
        main = "Super";
        ssm = "Super+Shift";
        sas = "Super+Alt+Shift";
        sam = "Super+Alt";
        scm = "Super+Control";
        scam = "Super+Control+Alt";
	ssc = "Super+Shift+Control";
      in {
        default-layout = "${layout}";
        set-repeat = "50 300";
	xcursor-theme = "BreezeX-RosePine-Linux 24";
        keyboard-layout = "-options \"caps:escape\" us";
        
	border-width = toString borderSize;
        background-color = "0x${colors.base00}";
	border-color-focused = "0x${colors.base05}";
	border-color-unfocused = "0x${colors.base01}";
	border-color-urgent = "0x${colors.base09}";

	spawn = [
          "\"${layout} ${layoutOptions}\""
	  "\"systemctl --user restart waybar\""
	];
	map = (lib.attrsets.recursiveUpdate ({
          normal = {
	    "${main} Q" = "close";
	    "${ssm} E" = "spawn \"systemctl --user stop waybar && riverctl exit\"";
	    
            # Basic utilities
	    "${main} X " = "spawn \"waylock -fork-on-lock ${waylockOptions}\"";
	    "${ssm} Return" = "spawn foot";
            "${main} P" = "spawn \"rofi -show drun\"";
	    "${ssm} P" = "spawn rofi-rbw";

	    # Window focus
	    "${main} J" = "focus-view next";
	    "${main} K" = "focus-view previous";

	    # Swap windows
	    "${ssm} J" = "swap next";
	    "${ssm} K" = "swap previous";
	    "${main} Return" = "zoom";

	    # Main ratio
	    "${main} H" = "send-layout-cmd rivertile 'main-ratio -0.05'";
	    "${main} L" = "send-layout-cmd rivertile 'main-ratio +0.05'";

	    # Main count
	    "${ssm} H" = "send-layout-cmd rivertile 'main-count +1'";
	    "${ssm} L" = "send-layout-cmd rivertile 'main-count -1'";

            # Tags
	    "${main} 0" = "set-focused-tags ${toString (pow2 32 - 1)}";
	    "${ssm} 0" = "set-view-tags ${toString (pow2 32 - 1)}";

	    # Orientation
	    "${main} Up" = "send-layout-cmd rivertile \"main-location top\"";
	    "${main} Right" = "send-layout-cmd rivertile \"main-location right\"";
	    "${main} Down" = "send-layout-cmd rivertile \"main-location bottom\"";
	    "${main} Left" = "send-layout-cmd rivertile \"main-location left\"";

            # Move floating windows
	    "${sam} H" = "move left 100";
	    "${sam} J" = "move down 100";
	    "${sam} K" = "move up 100";
	    "${sam} L" = "move right 100";

            # Snap floating windows
	    "${scam} H" = "snap left";
	    "${scam} J" = "snap down";
	    "${scam} K" = "snap up";
	    "${scam} L" = "snap right";

	    # Resize floating windows
	    "${sas} H" = "resize horizontal -100";
	    "${sas} J" = "resize vertical 100";
	    "${sas} K" = "resize vertical -100";
	    "${sas} L" = "resize horizontal 100";

	    # Toggle modes
	    "${main} Space" = "toggle-float";
	    "${main} F" = "toggle-fullscreen";
          } // builtins.listToAttrs (builtins.concatLists (map (tag: [
	    { name = "${main} ${toString tag}"; value = "set-focused-tags ${toString (pow2 (tag - 1))}"; }
	    { name = "${ssm} ${toString tag}"; value = "set-view-tags ${toString (pow2 (tag - 1))}"; }
	    { name = "${scm} ${toString tag}"; value = "toggle-focused-tags ${toString (pow2 (tag - 1))}"; }
	    { name = "${ssc} ${toString tag}"; value = "toggle-view-tags ${toString (pow2 (tag - 1))}"; }
	  ]) tags)); 
        }) (builtins.listToAttrs (map (mode: {
          name = "${mode}";
	  value = {
	    # Control volume
            "None XF86AudioRaiseVolume" = "spawn \"pulsemixer --change-volume +5\"";
	    "None XF86AudioLowerVolume" = "spawn \"pulsemixer --change-volume -5\"";
	    "None XF86AudioMute" = "spawn \"pulsemixer --toggle-mute\"";

	    # Control brightness
	    "None XF86MonBrightnessUp" = "spawn \"brightnessctl set +5%\"";
	    "None XF86MonBrightnessDown" = "spawn \"brightnessctl set 5%-\"";

	    # Control music playback
	    "None XF86Messenger" = "spawn \"playerctl previous\"";
	    "None XF86Go" = "spawn \"playerctl play-pause\"";
	    "None Cancel" = "spawn \"playerctl next\"";
	  };
	}) modes)));
	map-pointer = {
          normal = {
            "${main} BTN_LEFT" = "move-view";
	    "${main} BTN_RIGHT" = "resize-view";
	    "${main} BTN_MIDDLE" = "toggle-float";
	  };
	};
	input = {
	  "'*'" = {
	    accel-profile = "adaptive";
	    pointer-accel = "0.5";
	    scroll-factor = "0.8";
	  };
	  "'*Synaptics*'" = {
            natural-scroll = "enabled";
	  };
	};
	rule-add = {
          "-app-id" = {
	    "'bar'" = "csd";
            "'*'" = "ssd";
	  };
	};
      };
    };

    home.stateVersion = "24.05";
  };

  # Global neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # dconf
  programs.dconf.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    my-wqy-zenhei
    my-wqy-microhei
    my-wqy-bitmapsong
    cozette
    #uw-ttyp0
    #ucs-fonts
    dina-font # Cool but too small :(
    #unifont # Replace with Kissinger2
    #unifont_upper # Replace with Kissinger 2
    (nerdfonts.override { fonts = ["NerdFontsSymbolsOnly"]; })
  ];
  fonts.fontconfig.defaultFonts = {
    serif = [
      "DejaVu Serif"
    ];
    sansSerif = [
      "DejaVu Sans"
    ];
    monospace = [
      "Dina"
    ];
    emoji = [
      "CozetteVector"
      "Noto Color Emoji"
    ];
  };
  fonts.fontconfig.localConf = ''
    <alias>
      <family>Dina</family>
      <prefer>
        <family>Dina</family>
        <family>Cozette</family>
        <family>CozetteVector</family>
        <family>Fixed</family>
        <family>Symbols Nerd Font Mono</family>
        <family>WenQuanYi Bitmap Song</family>
      </prefer>
    </alias>
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    wget
    curl
    brightnessctl
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}