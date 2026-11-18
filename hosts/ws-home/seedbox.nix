{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

# Always-on torrent client, confined to a VPN-only network namespace, plus a
# read-only, password-protected WebDAV share of its downloads for the local network.
#
# Everything provider-specific lives in secrets:
#   seedbox/wireguard       wg-quick style config (keys, peer, Address, DNS, MTU)
#   seedbox/port            the incoming port forwarded by the VPN
#   seedbox/share-password  password for the share (user "seedbox")
#
# Web interface: only on this host's localhost, e.g. `ssh -L 8081:127.0.0.1:8081 ws-home`
let
  netns = "seedbox";
  wgIf = "wg-seedbox";
  dataDir = "/var/lib/seedbox";
  downloadsDir = "${dataDir}/downloads";
  webuiProxyPort = 8081; # localhost of this host only
  webuiPort = 8080; # inside the namespace
  sharePort = 8091;

  secret = name: config.sops.secrets."seedbox/${name}".path;
  secretFile = "${inputs.secrets}/secrets/ws-home.enc.yaml";

  user = config.services.qbittorrent.user;
  group = config.services.qbittorrent.group;
  inNetns = {
    NetworkNamespacePath = "/run/netns/${netns}";
  };
  netnsDeps = {
    bindsTo = [ "seedbox-netns.service" ];
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

  # Network namespace whose only route out is the WireGuard interface. The interface
  # is created here and moved into the namespace, so its encrypted traffic uses the
  # host's network, but nothing inside the namespace can reach anything else.
  systemd.services.seedbox-netns = {
    description = "Network namespace for the seedbox";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [
      iproute2
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

      ip link add ${wgIf} type wireguard
      wg setconf ${wgIf} <(wg-quick strip "$conf")
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

      # DNS only through the tunnel
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
      # Resolve names only with the tunnel's DNS. The host's nscd would resolve them
      # outside the namespace, so it is hidden.
      BindReadOnlyPaths = [
        "/run/seedbox/resolv.conf:/etc/resolv.conf"
        "/run/seedbox/nsswitch.conf:/etc/nsswitch.conf"
      ];
      InaccessiblePaths = [ "-/run/nscd" ];
      ReadWritePaths = [ dataDir ];

      # Initial settings, and the incoming port from the secret on every start. Other
      # settings are left to the web interface.
      ExecStartPre = pkgs.writeShellScript "seedbox-config" ''
        set -euo pipefail
        PATH=${
          lib.makeBinPath (
            with pkgs;
            [
              coreutils
              gnused
            ]
          )
        }
        port=$(tr -dc 0-9 < ${secret "port"})
        cfg=${dataDir}/qBittorrent/config/qBittorrent.conf
        mkdir -p ${downloadsDir} "$(dirname "$cfg")"
        if [ ! -f "$cfg" ]; then
          cat > "$cfg" <<EOF
        [BitTorrent]
        Session\DefaultSavePath=${downloadsDir}
        Session\Interface=${wgIf}
        Session\InterfaceName=${wgIf}
        Session\LSDEnabled=false
        Session\QueueingSystemEnabled=false
        Session\Port=$port

        [Network]
        PortForwardingEnabled=false

        [Preferences]
        WebUI\Address=127.0.0.1
        WebUI\Port=${toString webuiPort}
        EOF
        else
          sed -i -E "s|^Session\\\\Port=.*|Session\\\\Port=$port|" "$cfg"
        fi
      '';
    };
  };

  # Web interface on this host's localhost, proxied into the namespace
  systemd.sockets.seedbox-webui = {
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "127.0.0.1:${toString webuiProxyPort}" ];
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

  # Read-only share of the downloads on the local network, password protected and
  # not announced anywhere
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
  networking.firewall.interfaces.eno1.allowedTCPPorts = [ sharePort ];
}
