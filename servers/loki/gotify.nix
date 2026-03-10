{ config, ... }:
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
  services.nginx.virtualHosts."notify.no-bull.sh" =
    mkProxyHost "http://127.0.0.1:${builtins.toString config.services.gotify.environment.GOTIFY_SERVER_PORT}";

  services.gotify = {
    enable = true;
    environment = {
      GOTIFY_DATABASE_DIALECT = "postgres";
      GOTIFY_REGISTRATION = "false";
      GOTIFY_SERVER_CORS_ALLOWMETHODS = "[GET, POST]";
      GOTIFY_SERVER_CORS_ALLOWORIGINS = "[notify.no-bull.sh]";
      GOTIFY_SERVER_KEEPALIVEPERIODSECONDS = 0;
      GOTIFY_SERVER_PORT = 9072;
      GOTIFY_SERVER_SSL_ENABLED = "false";
      GOTIFY_SERVER_TRUSTED_PROXIES = "[127.0.0.1]";
    };
    environmentFiles = [ config.age.secrets."gotify.age".path ];
  };

  age.secrets."gotify.age" = {
    file = ../../secrets/gotify.age;
  };
}
