{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.firefox;
in
{
  options.modules.firefox = {
    enable = lib.mkEnableOption "firefox";
    default = lib.mkEnableOption "default";
  };

  config = lib.mkIf cfg.enable {
    default.browser = mkIf cfg.default "firefox.desktop";

    # Enable NUR
    nixpkgs.config.packageOverrides = pkgs: {
      # TODO: Pin the version
      nur = import (builtins.fetchTarball {
        url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
        sha256 = "0jjfvr325imrwg9ic8xha5y38jcp1s0z4pzwhvi0570aigzibbz4";
      }) { inherit pkgs; };
    };

    programs.firefox = {
      enable = true;

      policies = {
        AppAutoUpdate = false;
        # BlockAboutAddons = true;
        # BlockAboutConfig = true;
        # BlockAboutProfiles = true;
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
        DNSOverHTTPS = {
          Enabled = false;
        };
        DontCheckDefaultBrowser = true;
        PasswordManagerEnabled = false;
        TranslateEnabled = true;
        UseSystemPrintDialog = true;
      };

      profiles.nixos = {
        search.default = "DuckDuckGo";

        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          # firefox-color
          ublock-origin
        ];

        # Theming
        userChrome = readFile (
          pkgs.substituteAll {
            src = ./userChrome.css;
            colors = config.theming.colorsCSS;
          }
        );

        settings = {
          "browser.tabs.inTitlebar" = 0;
          "extensions.autoDisableScopes" = 0;
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };

        # Force overwriting configuration file
        search.force = true;
        containersForce = true;
      };
    };
  };
}
