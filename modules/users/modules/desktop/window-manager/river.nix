{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.river;
in
{
  options.modules.river.enable = lib.mkEnableOption "river";

  # osConfig = lib.mkIf cfg.enable {
  #   programs.river.enable = true;
  # };

  config = lib.mkIf cfg.enable {
    # Set desktop type to wayland
    modules.desktop.wayland = true;

    # TODO: Move elsewhere and make keybindings more configurable
    modules.rofi.enable = true;

    # TODO: Move elsewhere
    home.packages = with pkgs; [
      brightnessctl
      # owm
    ];

    # Change desktop to execute river
    modules.desktop.initScript = ''
      river
    '';

    # Update background after rebuild
    # home.activation = {
    #   river = lib.hm.dag.entryBetween [ "reloadSystemd" ] [ "installPackages" ] ''
    #     # Close waybar
    #     PATH="${pkgs.procps}/bin:$PATH" $DRY_RUN_CMD pkill waybar

    #     # Kill rivertile
    #     PATH="${pkgs.procps}/bin:$PATH" $DRY_RUN_CMD pkill rivertile

    #     # Kill glpaper
    #     PATH="${pkgs.procps}/bin:$PATH" $DRY_RUN_CMD pkill glpaper

    #     # Restart river
    #     PATH="${pkgs.river}/bin:${pkgs.systemd}/bin:${pkgs.waybar}/bin:$PATH" $DRY_RUN_CMD ~/.config/river/init
    #   '';
    # };

    # River setup
    wayland.windowManager.river = {
      enable = true;
      xwayland.enable = true;
      settings =
        let
          layout = "rivertile";
          layoutOptions = "-outer-padding ${toString config.theming.layout.windowPadding} -view-padding ${toString config.theming.layout.windowPadding}";
          modes = [
            "normal"
            "locked"
          ];
          tags = [
            1
            2
            3
            4
            5
            6
            7
            8
            9
          ];
          waylockOptions = "-init-color 0x${colors.bg} -input-color 0x${colors.border-focused} -fail-color 0x${colors.bg}";

          colors = config.theming.colors;

          # Quick pow function
          pow2 = power: if power != 0 then 2 * (pow2 (power - 1)) else 1;

          # Modifiers
          main = "Super";
          ssm = "Super+Shift";
          sas = "Super+Alt+Shift";
          sam = "Super+Alt";
          scm = "Super+Control";
          scam = "Super+Control+Alt";
          ssc = "Super+Shift+Control";
        in
        {
          default-layout = "${layout}";
          set-repeat = "50 300";
          xcursor-theme = "BreezeX-RosePine-Linux 24";
          keyboard-layout = "-options \"caps:escape\" us";

          border-width = toString config.theming.layout.borderSize;
          background-color = "0x${colors.bg}";
          border-color-focused = "0x${colors.fg}";
          border-color-unfocused = "0x${colors.border-unfocused}"; # TODO: Change to use named color;
          border-color-urgent = "0x${colors.fg}";

          spawn = [
            "\"${layout} ${layoutOptions}\""
            "waybar"
            "\"glpaper eDP-1 ${toString config.modules.glpaper.shader}\""
          ];
          map = (
            lib.attrsets.recursiveUpdate
              ({
                normal =
                  {
                    "${main} Q" = "close";
                    "${ssm} E" = "exit";

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
                  }
                  // builtins.listToAttrs (
                    builtins.concatLists (
                      map (tag: [
                        {
                          name = "${main} ${toString tag}";
                          value = "set-focused-tags ${toString (pow2 (tag - 1))}";
                        }
                        {
                          name = "${ssm} ${toString tag}";
                          value = "set-view-tags ${toString (pow2 (tag - 1))}";
                        }
                        {
                          name = "${scm} ${toString tag}";
                          value = "toggle-focused-tags ${toString (pow2 (tag - 1))}";
                        }
                        {
                          name = "${ssc} ${toString tag}";
                          value = "toggle-view-tags ${toString (pow2 (tag - 1))}";
                        }
                      ]) tags
                    )
                  );
              })
              (
                builtins.listToAttrs (
                  map (mode: {
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
                  }) modes
                )
              )
          );
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
              "'wpa_gui'" = "float";
            };
          };
        };
    };
  };
}
