{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.neovim;
  theme = config.desktop.theming;
  colors = theme.colors;
in
{
  options.modules.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      extraPackages = with pkgs; [ ];

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
          fg = theme.schemeColors.withHashtag.base03; # TODO: Come up with a good name colors.muted maybe?
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

      plugins.web-devicons = {
        enable = true;
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

      # plugins.vimtex = {
      #   enable = true;
      #   texlivePackage = null;
      #   settings = {
      #     view_method = "zathura";
      #   };
      # };
    };
    programs.neovim.defaultEditor = true;
  };
}
