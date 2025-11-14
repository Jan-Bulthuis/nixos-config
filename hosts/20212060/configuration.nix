{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  # State version
  system.stateVersion = "24.05";

  # Machine hostname
  networking.hostName = "20212060";

  # Admin users
  users.users.jan.extraGroups = [
    "wheel"
    "wireshark"
    "podman"
  ];

  # Set up kerberos
  security.krb5 = {
    enable = true;
    settings = {
      libdefaults = {
        rdns = false;
      };
      realms = (inputs.secrets.gewis.krb5Realm);
    };
  };

  services.netbird = {
    enable = true;
  };

  # TODO: Move clatd setup

  # services.clatd = {
  #   enable = true;
  #   enableNetworkManagerIntegration = true;
  # };
  # networking.networkmanager.settings = {
  #   connection."ipv6.clat" = "yes";
  # };
  networking.networkmanager.package = pkgs.networkmanager.overrideAttrs (
    final: prev: {
      src = pkgs.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "Mstrodl";
        repo = "NetworkManager";
        # rev = "d367285a1fec5167f2fa94af2ea1448b6e21650e";
        # sha256 = "0BHxuJ6KtFoVxh2Xt0bq4oM3q87QBhtawyMtixz/cPs=";
        rev = "fa3b0c6ade05a67316520d143608c5bd9963a23c";
        hash = "sha256-7TENrRDKXMFPWv6oDuBWBYIBrDvNsy/JGtkppMk1oQo=";
      };

      postPatch = prev.postPatch + ''
        substituteInPlace meson.build \
          --replace "find_program('clang'" "find_program('${pkgs.stdenv.cc.targetPrefix}clang'"
      '';

      hardeningDisable = [
        "zerocallusedregs"
        "shadowstack"
        "pacret"
      ];

      nativeBuildInputs =
        prev.nativeBuildInputs
        ++ (with pkgs; [
          xdp-tools
          bpftools
          buildPackages.llvmPackages.clang
          buildPackages.llvmPackages.libllvm
        ]);

      buildInputs =
        prev.buildInputs
        ++ (with pkgs; [
          libbpf
        ]);

      mesonFlags = prev.mesonFlags ++ [
        "-Dclat=true"
        "-Dnbft=false"
        "-Dbpf-compiler=clang"
      ];
    }
  );

  # TODO: Remove once laptop is properly integrated into domain
  programs.ssh = {
    package = pkgs.openssh_gssapi;
    extraConfig = ''
      GSSAPIAuthentication yes
    '';
  };

  # Enable virtualisation for VMs
  virtualisation.libvirtd.enable = true;

  # Enable wireshark
  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    usbmon.enable = true;
  };

  # Enable Nix-LD
  programs.nix-ld = {
    enable = true;
  };

  # Set up wstunnel client
  services.wstunnel = {
    enable = true;
    clients.wg-tunnel = {
      connectTo = "wss://tunnel.bulthuis.dev:443";
      settings.local-to-remote = [
        "udp://51820:10.10.40.100:51820"
      ];
    };
  };

  # Enable flatpak
  services.flatpak.enable = true;

  # Set up MADD
  # services.madd-client = {
  #   enable = true;
  #   endpoint = "http://localhost:3000";
  #   interface = "wlp0s20f3";
  # };
  # services.madd-server = {
  #   enable = true;
  #   settings = {
  #     bind = "127.0.0.1:3000";
  #     zone = "lab.bulthuis.dev";
  #     networks = [ "10.0.0.0/8" ];
  #     registration_limit = 1;
  #     dns_server = "127.0.0.1:2053";
  #     tsig_key_name = "madd";
  #     tsig_key_file = "/home/jan/Code/MADD/madd.tsig";
  #     tsig_algorithm = "hmac-sha256";
  #     data_dir = "/var/lib/madd";
  #   };
  # };

  # Module setup
  modules = {
    profiles.laptop.enable = true;
  };

  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    autoPrune.enable = true;
  };

  environment.systemPackages =
    let
      wrapProgram =
        pkg: bwrapArgs:
        pkgs.runCommandLocal pkg.name { bwrapArgs = (lib.join " \\\n" bwrapArgs) + " \\"; } ''
          mkdir -p $out

          # Link all top level folders
          ln -s ${pkg}/* $out

          # Except for bin
          rm $out/bin
          mkdir -p $out/bin

          # Wrap each executable
          for file in ${pkg}/bin/*; do
            base=$(basename $file)
            echo "#!/usr/bin/env bash" > $out/bin/$base
            echo "exec ${pkgs.bubblewrap}/bin/bwrap \\" >> $out/bin/$base
            echo "$bwrapArgs" >> $out/bin/$base
            echo "-- $file \"\$@\"" >> $out/bin/$base
            chmod +x $out/bin/$base
          done
        '';
      wish = pkgs.writeShellScriptBin "wish" ''
        env
        exec ${lib.getExe pkgs.firefox} "$@"
      '';
    in
    [
      (wrapProgram wish [
        "--new-session"
        "--unshare-all"
        "--clearenv"
        "--dev /dev"
        "--proc /proc"
        "--ro-bind /nix/store /nix/store"
        "--bind $HOME/Code $HOME/Code"
      ])
    ];
}
