{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.beatsaber-oneclick;
in
{
  options.modules.beatsaber-oneclick = {
    enable = mkEnableOption "forwarding Beat Saber OneClick links to a Steam Frame";

    host = mkOption {
      type = types.str;
      example = "steamos@frame.local";
      description = "SSH destination of the Steam Frame. Needs key auth, as there is no terminal to ask for a password.";
    };
  };

  config = mkIf cfg.enable {
    # The schemes BSManager handles on the Frame. Registering them here makes
    # browsers on this machine hand the links to the Frame.
    xdg.desktopEntries.beatsaber-oneclick = {
      name = "Beat Saber OneClick (Steam Frame)";
      comment = "Install Beat Saber maps and playlists on the Steam Frame";
      type = "Application";
      exec = "${pkgs.beatsaber-oneclick}/bin/beatsaber-oneclick ${escapeShellArg cfg.host} %u";
      terminal = false;
      noDisplay = true;
      mimeType = [
        "x-scheme-handler/beatsaver"
        "x-scheme-handler/bsplaylist"
        "x-scheme-handler/web+bsmap"
        "x-scheme-handler/modelsaber"
      ];
    };
  };
}
