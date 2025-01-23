{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
{
  imports = [
    ./firefox/default.nix
    ./qutebrowser/default.nix
  ];

  options.default.browser = mkOption {
    type = types.str;
    default = "";
    description = "Default browser";
  };

  config = {
    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "text/html" = "${config.default.browser}";
        "x-scheme-handler/http" = "${config.default.browser}";
        "x-scheme-handler/https" = "${config.default.browser}";
        "x-scheme-handler/about" = "${config.default.browser}";
        "x-scheme-handler/unknown" = "${config.default.browser}";
      };
    };
  };
}
