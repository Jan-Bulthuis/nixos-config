{
  lib,
  pkgs,
  config,
  ...
}:

{
  # State version
  system.stateVersion = "24.11";

  # Machine hostname
  networking.hostName = "vm-vpn";

  # Enabled modules
  modules = {
    profiles.vm.enable = true;
  };

  # Setup wstunnel server
  services.wstunnel = {
    enable = true;
    servers.wg-tunnel =
      let
        tlsFiles = pkgs.stdenvNoCC.mkDerivation {
          name = "tls-files";
          phases = [
            "buildPhase"
            "installPhase"
          ];
          buildPhase = ''
            ${pkgs.openssl}/bin/openssl genrsa > privkey.pem
            ${pkgs.openssl}/bin/openssl req -new -x509 -batch -key privkey.pem > fullchain.pem
          '';
          installPhase = ''
            mkdir -p $out
            cp privkey.pem fullchain.pem $out/
          '';
        };
      in
      {
        enableHTTPS = true;
        listen = {
          host = "0.0.0.0";
          port = 8080;
        };
        restrictTo = [
          {
            host = "10.10.40.100";
            port = 51820;
          }
        ];
        tlsCertificate = "${tlsFiles}/fullchain.pem";
        tlsKey = "${tlsFiles}/key.pem";
      };
  };
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
  };
}
