{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.steam-frame;
  kernel = config.boot.kernelPackages.kernel;

  # Out-of-tree rtw89 driver, as the in-tree rtw89_8852cu driver needs Linux 7.0+,
  # which ZFS does not support yet
  rtw89 = pkgs.stdenv.mkDerivation {
    pname = "rtw89-morrownr";
    version = "0-unstable-2026-11-09-${kernel.version}";

    src = pkgs.fetchFromGitHub {
      owner = "morrownr";
      repo = "rtw89";
      rev = "f2ce66eda6277e5505d5914a8a08454440518702";
      hash = "sha256-u2sJ/1tvDM6MloulU7l3w9eLCc2GZqOBebI7/eQbeC8=";
    };

    nativeBuildInputs = kernel.moduleBuildDependencies;
    makeFlags = kernel.commonMakeFlags ++ [
      "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ];
    buildFlags = [ "modules" ];

    # Install through Kbuild so the modules are signed (produces the .ko.cer files)
    installPhase = ''
      runHook preInstall
      local flagsArray=()
      concatTo flagsArray makeFlags
      make "''${flagsArray[@]}" -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$PWD \
        modules_install INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=updates/rtw89
      runHook postInstall
    '';

    meta.platforms = platforms.linux;
  };
in
{
  options.modules.steam-frame = {
    enable = mkEnableOption "Steam Frame wireless streaming adapter";

    regulatoryDomain = mkOption {
      type = types.str;
      description = "Country code to use for Wi-Fi, needed to unlock the 6 GHz band.";
    };
  };

  config = mkIf cfg.enable {
    # Driver for the adapter (Realtek RTL8832CU, 28de:2432)
    # Firmware comes from linux-firmware (hardware.enableRedistributableFirmware)
    boot.extraModulePackages = [ rtw89 ];
    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom=${cfg.regulatoryDomain}

      # The adapter tends to stall when it enters power saving
      options rtw89_core_git disable_ps_mode=y

      # Prevent the in-tree drivers from claiming the adapter
      blacklist rtw89_core
      blacklist rtw89_usb
      blacklist rtw89_8852c
      blacklist rtw89_8852cu
    '';

    # Never let the adapter doze. In power save the Frame (the access point) buffers
    # traffic for the PC until it wakes up, which stalls streams towards the PC
    # such as spectating. This overrides the global wifi.powersave for this driver only.
    networking.networkmanager.settings."connection-steam-frame" = {
      match-device = "driver:rtw89_8852cu_git";
      "wifi.powersave" = 2;
    };

    # Udev rules for Valve devices
    hardware.steam-hardware.enable = true;

    # Streaming ports
    networking.firewall = {
      allowedTCPPorts = [ 27036 ];
      allowedUDPPortRanges = [
        {
          from = 10400;
          to = 10401;
        }
        {
          from = 27031;
          to = 27036;
        }
      ];
    };

    environment.systemPackages = [ pkgs.iw ];
  };
}
