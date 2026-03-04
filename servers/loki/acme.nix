{ config, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@no-bull.sh";
    certs."no-bull.sh" = {
      domain = "no-bull.sh";
      extraDomainNames = [ "*.no-bull.sh" ];
      group = "nginx";
      dnsResolver = "9.9.9.9#53";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets."cloudflare-dns-token.age".path;
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  age.secrets."cloudflare-dns-token.age" = {
    owner = "acme";
    file = ../../secrets/cloudflare-dns-token.age;
  };
}
