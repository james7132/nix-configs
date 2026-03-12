{
  config,
  lib,
  pkgs,
  ...
}:
let
  nginxList = prefix: lib.strings.concatMapStringsSep "\n" (x: "${prefix} ${x};");
  realIpsFromList = nginxList "set_real_ip_from";
  fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
  cloudflareIPv4s = fileToList (
    pkgs.fetchurl {
      url = "https://www.cloudflare.com/ips-v4";
      sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
    }
  );
  cloudflareIPv6s = fileToList (
    pkgs.fetchurl {
      url = "https://www.cloudflare.com/ips-v6";
      sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
    }
  );
  localIPv4s = [
    "0.0.0.0/8"
    "10.0.0.0/8"
    "127.0.0.0/8"
    "192.168.0.0/16"
  ];
  ipv4AllowList = nginxList "allow" localIPv4s + "\n deny all;";
  mkProxyHost = url: allowExternal: {
    useACMEHost = "no-bull.sh";
    forceSSL = true;
    extraConfig = lib.mkIf (!allowExternal) ipv4AllowList;
    locations."/" = {
      proxyPass = url;
      proxyWebsockets = true;
    };
  };
in
{
  imports = [
    ../../modules/default.nix
    ./acme.nix
    ./cloudflare-ddns.nix
    ./bluesky-pds.nix
    ./servarr.nix
    ./gotify.nix
    ./hardware-configuration.nix
  ];

  host = {
    secure-boot.enable = true;
    desktop.enable = false;
    server.enable = true;
    nfs.enable = true;
  };

  networking.hostName = "loki";

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    commonHttpConfig = ''
      ${realIpsFromList cloudflareIPv4s}
      ${realIpsFromList cloudflareIPv6s}
      real_ip_header CF-Connecting-IP;
    '';

    appendHttpConfig = ''
      # Add HSTS header with preloading to HTTPS requests.
      # Adding this header to HTTP requests is discouraged
      map $scheme $hsts_header {
          https   "max-age=31536000; includeSubdomains; preload";
      }
      add_header Strict-Transport-Security $hsts_header;

      # Enable CSP for your services.
      #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
      add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;
    '';

    virtualHosts = {
      "default" = {
        useACMEHost = "no-bull.sh";
        forceSSL = true;
        default = true;
        extraConfig = "deny all;";
      };

      "no-bull.sh" = {
        useACMEHost = "no-bull.sh";
        forceSSL = true;
        root = "/var/www/no-bull.sh";
      };

      "files.no-bull.sh" = {
        useACMEHost = "no-bull.sh";
        forceSSL = true;
        root = "/mnt/leviathan/files/public";
        extraConfig = ''
          autoindex on;
          autoindex_exact_size off;
          autoindex_localtime on;
          index off;
        '';
        locations."~* .*\@eaDir.*" = {
          extraConfig = ''
            deny all;
          '';
        };
      };

      "i.no-bull.sh" = {
        useACMEHost = "no-bull.sh";
        forceSSL = true;
        root = "/mnt/leviathan/files/screenshots";
      };

      "ns1.no-bull.sh" = mkProxyHost "http://127.0.0.1:5380" false;

      "immich.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:2283" true;

      "jellyfin.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8096" false;
      "komga.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9123" false;

      "transmission.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9091" false;
      "freshrss.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9576" false;
      "hassio.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8123" false;

      "stats.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:7590" false;
      "sync.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8384" false;

      "vikunja.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:3456" false;

      "${config.services.libretranslate.domain}" = {
        useACMEHost = "no-bull.sh";
        forceSSL = true;
        extraConfig = ipv4AllowList;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };

  services.libretranslate = {
    enable = true;
    configureNginx = true;
    domain = "translate.no-bull.sh";
  };

  system.stateVersion = "25.11";
}
