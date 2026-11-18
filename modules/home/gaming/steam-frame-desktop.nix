{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.steam-frame-desktop;

  log = "${config.xdg.dataHome}/Steam/logs/streaming_log.txt";

  setScale = scale: "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface text-scaling-factor ${toString scale}";

  # Follows Steam's streaming log, which marks when a desktop stream starts and stops
  # (Remote Play "Connect" on the Frame, or the desktop view in PC VR)
  watcher = pkgs.writeShellScript "steam-frame-desktop-scale" ''
    ${pkgs.coreutils}/bin/tail -n 0 -F ${escapeShellArg log} 2>/dev/null | while IFS= read -r line; do
      case "$line" in
        *">>> Starting desktop stream"*)
          ${setScale cfg.streamingTextScale} ;;
        # Also reset when Steam restarts, in case it quit mid-stream
        *">>> Stopped desktop stream"* | *"Client version:"*)
          ${setScale cfg.normalTextScale} ;;
      esac
    done
  '';
in
{
  options.modules.steam-frame-desktop = {
    enable = mkEnableOption "larger text while the desktop is streamed to a Steam Frame";

    streamingTextScale = mkOption {
      type = types.float;
      default = 1.44;
      description = "GNOME text scaling factor while the desktop is being streamed.";
    };

    normalTextScale = mkOption {
      type = types.float;
      default = 1.0;
      description = "GNOME text scaling factor otherwise.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.steam-frame-desktop-scale = {
      Unit = {
        Description = "Scale text up while the desktop is streamed to a Steam Frame";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${watcher}";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
