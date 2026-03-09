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
  mkLocalProxyHost =
    service:
    mkIf service.enable (
      mkProxyHost "http://127.0.0.1:${builtins.toString service.settings.server.port}"
    );
  mkServarrService = serviceName: servicePort: {
    enable = true;
    openFirewall = false;
    settings = {
      app = {
        theme = "dark";
      };
      server = {
        port = servicePort;
        enableSsl = false;
      };
      log = {
        analyticsEnabled = false;
        logLevel = "info";
      };
      auth = {
        authenticationMethod = "Forms";
        authenticationRequried = true;
      };
    };
    environmentFiles = [ config.age.secrets."${serviceName}.age".path ];
  };
in
{
  services.nginx = {
    virtualHosts = {
      "radarr.no-bull.sh" = mkLocalProxyHost config.services.radarr;
      "sonarr.no-bull.sh" = mkLocalProxyHost config.services.sonarr;
      "lidarr.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8686";
      "bazarr.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:6767";
      "prowlarr.no-bull.sh" = mkLocalProxyHost config.services.prowlarr;
    };
  };

  services.sonarr = mkServarrService "sonarr" 8989;
  services.radarr = mkServarrService "radarr" 7878;
  services.prowlarr = mkServarrService "prowlarr" 9696;

  age.secrets."sonarr.age" = {
    owner = config.services.sonarr.user;
    file = ../../secrets/sonarr.age;
  };

  age.secrets."radarr.age" = {
    owner = config.services.radarr.user;
    file = ../../secrets/radarr.age;
  };

  age.secrets."prowlarr.age" = {
    owner = "prowlarr";
    file = ../../secrets/prowlarr.age;
  };
}
