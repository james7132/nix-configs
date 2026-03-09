{ config, lib, ... }:
with lib;
let
  mkProxyHost = url: {
    useACMEHost = "no-bull.sh";
    forceSSL = true;
    locations."/" = {
      proxyPass = url;
      proxyWebsockets = true;
    };
  };
in
{
  services.nginx.virtualHosts."pds.no-bull.sh" = mkIf config.services.bluesky-pds.enable (
    mkProxyHost "http://127.0.0.1:${builtins.toString config.services.bluesky-pds.settings.PDS_PORT}"
  );

  services.bluesky-pds = {
    enable = true;
    pdsadmin.enable = true;
    environmentFiles = [ config.age.secrets."bluesky-pds.age".path ];
    settings = {
      PDS_PORT = 7070;
      PDS_HOSTNAME = "pds.no-bull.sh";
    };
  };

  age.secrets."bluesky-pds.age" = {
    owner = "pds";
    file = ../../secrets/bluesky-pds.age;
  };
}
