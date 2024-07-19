{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.waybar;
  theme = config.theming;
  colors = theme.colors;
in
{
  options.modules.waybar = {
    enable = mkEnableOption "waybar";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pulsemixer
      playerctl
    ];

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          spacing = 16;
          modules-left = [ "river/tags" ];
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
              default = [
                ""
                ""
                ""
              ];
            };
          };
          battery = {
            format = "{icon} {capacity}%"; # Spacing achieved using "Thin Space"
            format-charging = " {capacity}%"; # Spacing achieved using "Thin Space"
            #format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
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
      # TODO: Replace base03 color with named color
      style = ''
        window#waybar {
          color: #${colors.fg};
          background-color: #${colors.bg};
          border-style: none none solid none;
          border-width: ${toString theme.layout.borderSize}px;
          border-color: #${colors.border-unfocused};
          font-size: 12px;
          font-family: "${theme.fonts.monospace.name}";
        }

        .modules-right {
          margin: 0 8px 0 0;
        }

        #tags button {
          color: #${theme.schemeColors.base03};
          padding: 0 5px 1px 5px;
          border-radius: 0;
          font-size: 16px;
          font-family: "Unifont";
        }

        #tags button.occupied {
          color: #${colors.fg};
        }

        #tags button.focused {
          color: #${colors.accent};
        }
      '';
    };
  };
}
