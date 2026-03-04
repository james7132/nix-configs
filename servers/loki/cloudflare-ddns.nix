{ config, ... }:
{
  services.cloudflare-ddns = {
    enable = true;
    ttl = 300;
    proxied = "true";
    domains = [ "no-bull.sh" ];
    user = "cloudflare-ddns";
    credentialsFile = config.age.secrets."cloudflare-ddns.age".path;
  };

  age.secrets."cloudflare-ddns.age" = {
    owner = "cloudflare-ddns";
    file = ../../secrets/cloudflare-ddns.age;
  };
}
