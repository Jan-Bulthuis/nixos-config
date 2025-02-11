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

    programs.firefox = {
      enable = true;

      policies = {
        AppAutoUpdate = false;
        BlockAboutAddons = false;
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
          ublock-origin
          tridactyl # TODO: Add toggle for this extension?
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
