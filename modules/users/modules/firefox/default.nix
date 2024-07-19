{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.firefox;
in
{
  options.modules.firefox.enable = lib.mkEnableOption "firefox";

  config = lib.mkIf cfg.enable {
    # Enable NUR
    nixpkgs.config.packageOverrides = pkgs: {
      # TODO: Pin the version
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };

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

        extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-origin ];

        settings = {
          "browser.tabs.inTitlebar" = 0;
          "extensions.autoDisableScopes" = 0;
        };

        # Force overwriting configuration file
        search.force = true;
        containersForce = true;
      };
    };
  };
}
