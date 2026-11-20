{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

# Torrent client confined to a VPN-only network namespace, plus a WebDAV share.
# See seedbox.md.
let
  netns = "seedbox";
  wgIf = "wg-seedbox";
  dataDir = "/var/lib/seedbox";
  downloadsDir = "${dataDir}/downloads";
  certDir = "${dataDir}/webui-tls";
  webuiPort = 8081;
  sharePort = 8091;
  inherit (config.networking) hostName;

  secret = name: config.sops.secrets."seedbox/${name}".path;
  secretFile = "${inputs.secrets}/secrets/ws-home.enc.yaml";

  user = config.services.qbittorrent.user;
  group = config.services.qbittorrent.group;
  inNetns = {
    NetworkNamespacePath = "/run/netns/${netns}";
  };
  netnsDeps = {
    bindsTo = [ "seedbox-netns.service" ];
    partOf = [ "seedbox-netns.service" ];
    after = [ "seedbox-netns.service" ];
  };
in
{
  sops.secrets = {
    "seedbox/wireguard".sopsFile = secretFile;
    "seedbox/port" = {
      sopsFile = secretFile;
      owner = user;
    };
    "seedbox/share-password" = {
      sopsFile = secretFile;
      owner = user;
    };
  };

  modules.impermanence.directories = [
    {
      directory = dataDir;
      inherit user group;
      mode = "0750";
    }
  ];
  systemd.tmpfiles.rules = [ "d ${downloadsDir} 0750 ${user} ${group} -" ];

  boot.kernelModules = [ "tcp_bbr" ];

  systemd.services.seedbox-netns = {
    description = "Network namespace for the seedbox";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [
      iproute2
      procps
      wireguard-tools
      gnugrep
      gnused
      coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "seedbox";
      RuntimeDirectoryPreserve = true;
    };
    script = ''
      set -euo pipefail
      conf=${secret "wireguard"}
      field() { grep -iE "^\s*$1\s*=" "$conf" | cut -d= -f2- | tr ',' '\n' | sed 's/ //g'; }

      ip netns del ${netns} 2>/dev/null || true
      ip link del ${wgIf} 2>/dev/null || true

      ip netns add ${netns}
      ip -n ${netns} link set lo up

      # wg-quick strip requires a .conf file name
      stripped=$(grep -viE '^\s*(Address|DNS|MTU|Table|SaveConfig|(Pre|Post)(Up|Down))\s*=' "$conf")
      if ! grep -qi '^\s*PrivateKey' <<<"$stripped" || ! grep -qi '^\s*\[Peer\]' <<<"$stripped"; then
        echo "seedbox/wireguard has no PrivateKey or [Peer]" >&2
        exit 1
      fi

      ip link add ${wgIf} type wireguard
      wg setconf ${wgIf} <(printf '%s\n' "$stripped")
      if ! wg show ${wgIf} peers | grep -q .; then
        echo "WireGuard peer was not configured" >&2
        exit 1
      fi
      ip link set ${wgIf} netns ${netns}
      for addr in $(field Address); do
        ip -n ${netns} addr add "$addr" dev ${wgIf}
      done
      mtu=$(field MTU | head -1)
      ip -n ${netns} link set ${wgIf} mtu "''${mtu:-1420}" up
      ip -n ${netns} route add default dev ${wgIf}
      if field Address | grep -q ':'; then
        ip -n ${netns} -6 route add default dev ${wgIf}
      fi

      # Faster TCP to distant peers
      ip netns exec ${netns} sysctl -q -w \
        net.ipv4.tcp_congestion_control=bbr \
        net.ipv4.tcp_wmem="4096 65536 16777216" \
        net.ipv4.tcp_rmem="4096 131072 16777216" \
        net.ipv4.tcp_slow_start_after_idle=0

      field DNS | grep -v ':' | sed 's/^/nameserver /' > /run/seedbox/resolv.conf
      echo 'hosts: files dns' > /run/seedbox/nsswitch.conf
    '';
    preStop = ''
      ip netns del ${netns} || true
    '';
  };

  services.qbittorrent = {
    enable = true;
    profileDir = dataDir;
    inherit webuiPort;
    extraArgs = [ "--confirm-legal-notice" ];
  };

  systemd.services.qbittorrent = netnsDeps // {
    serviceConfig = inNetns // {
      # nscd would bypass the tunnel's DNS
      BindReadOnlyPaths = [
        "/run/seedbox/resolv.conf:/etc/resolv.conf"
        "/run/seedbox/nsswitch.conf:/etc/nsswitch.conf"
      ];
      InaccessiblePaths = [ "-/run/nscd" ];
      ReadWritePaths = [ dataDir ];

      ExecStartPre = pkgs.writeShellScript "seedbox-config" ''
        set -euo pipefail
        PATH=${
          lib.makeBinPath (
            with pkgs;
            [
              coreutils
              crudini
              openssl
            ]
          )
        }
        cfg=${dataDir}/qBittorrent/config/qBittorrent.conf
        mkdir -p ${downloadsDir} "$(dirname "$cfg")"
        set_() { crudini --ini-options=nospace --set "$cfg" "$@"; }

        if [ ! -f ${certDir}/cert.pem ]; then
          mkdir -p ${certDir}
          openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes \
            -days 3650 -subj /CN=${hostName} -addext subjectAltName=DNS:${hostName},DNS:seedbox.bulthuis.dev \
            -keyout ${certDir}/key.pem -out ${certDir}/cert.pem
          chmod 600 ${certDir}/key.pem
        fi

        if [ ! -f "$cfg" ]; then
          touch "$cfg"
          set_ BitTorrent 'Session\DefaultSavePath' ${downloadsDir}
          set_ BitTorrent 'Session\LSDEnabled' false
          set_ BitTorrent 'Session\QueueingSystemEnabled' false
        fi

        set_ BitTorrent 'Session\Port' "$(tr -dc 0-9 < ${secret "port"})"
        set_ BitTorrent 'Session\Interface' ${wgIf}
        set_ BitTorrent 'Session\InterfaceName' ${wgIf}
        set_ Network PortForwardingEnabled false
        # qBittorrent 5 reads these from [WebUI], drop the old keys
        for k in Address Port HostHeaderValidation LocalHostAuth 'HTTPS\Enabled' 'HTTPS\CertificatePath' 'HTTPS\KeyPath'; do
          crudini --del "$cfg" Preferences "WebUI\\$k"
        done
        set_ WebUI 'Address' 127.0.0.1
        set_ WebUI 'Port' ${toString webuiPort}
        set_ WebUI 'HostHeaderValidation' false
        # Proxied clients appear as localhost, so they must not skip the login
        set_ WebUI 'LocalHostAuth' true
        set_ WebUI 'HTTPS\Enabled' true
        set_ WebUI 'HTTPS\CertificatePath' ${certDir}/cert.pem
        set_ WebUI 'HTTPS\KeyPath' ${certDir}/key.pem
      '';
    };
  };

  systemd.sockets.seedbox-webui = {
    wantedBy = [ "sockets.target" ];
    listenStreams = [ (toString webuiPort) ];
  };
  systemd.services.seedbox-webui = netnsDeps // {
    requires = [ "qbittorrent.service" ];
    after = [ "qbittorrent.service" ];
    serviceConfig = inNetns // {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString webuiPort}";
      DynamicUser = true;
      PrivateTmp = true;
    };
  };

  systemd.services.seedbox-share = {
    description = "Seedbox downloads share";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = user;
      Group = group;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      ReadOnlyPaths = [ dataDir ];
    };
    script = ''
      export RCLONE_USER=seedbox
      RCLONE_PASS=$(cat ${secret "share-password"})
      export RCLONE_PASS
      exec ${lib.getExe pkgs.rclone} serve webdav ${downloadsDir} \
        --addr :${toString sharePort} --read-only --dir-cache-time 15s
    '';
  };
  networking.firewall.interfaces.eno1.allowedTCPPorts = [
    webuiPort
    sharePort
  ];
}
