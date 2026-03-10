{ ... }:
let
  localIPs = ''
    allow 0.0.0.0/8;
    allow 10.0.0.0/8;
    allow 127.0.0.0/8;
    allow 192.168.0.0/16;
  '';
  cloudflareIPs = ''
    allow 103.21.244.0/22;
    allow 103.22.200.0/22;
    allow 103.31.4.0/22;
    allow 104.16.0.0/13;
    allow 104.24.0.0/14;
    allow 108.162.192.0/18;
    allow 131.0.72.0/22;
    allow 141.101.64.0/18;
    allow 162.158.0.0/15;
    allow 172.64.0.0/13;
    allow 173.245.48.0/20;
    allow 188.114.96.0/20;
    allow 190.93.240.0/20;
    allow 197.234.240.0/22;
    allow 198.41.128.0/17;
  '';
  mkIPAllowlist =
    allowExternal: (if allowExternal then "${localIPs}\n${cloudflareIPs}" else localIPs);
  mkProxyHost = url: allowExternal: {
    useACMEHost = "no-bull.sh";
    forceSSL = true;
    extraConfig = mkIPAllowlist allowExternal + "\n deny all;";
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

    virtualHosts = {
      "no-bull.sh" = {
        useACMEHost = "no-bull.sh";
        forceSSL = true;
        default = true;
        root = "/var/www/no-bull.sh";
        extraConfig = mkIPAllowlist true;
      };

      "files.no-bull.sh" = {
        useACMEHost = "no-bull.sh";
        forceSSL = true;
        root = "/mnt/leviathan/files/public";
        extraConfig = mkIPAllowlist true + ''
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

  system.stateVersion = "25.11";
}
