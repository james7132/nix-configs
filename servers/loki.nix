{
  config,
  lib,
  modulesPath,
  ...
}:
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
# Hardware specific configuration for loki
{
  imports = [
    ../modules/default.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  host = {
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
      };

      "i.no-bull.sh" = {
        useACMEHost = "no-bull.sh";
        forceSSL = true;
        root = "/mnt/leviathan/files/screenshots";
      };

      "ns1.no-bull.sh" = mkProxyHost "http://127.0.0.1:5380";
      "ns2.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:5830";

      "immich.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:2283";
      "notify.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9072";

      "jellyfin.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8096";
      "radarr.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:7878";
      "sonarr.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8989";
      "lidarr.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8686";
      "bazarr.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:6767";
      "prowlarr.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9696";
      "komga.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9123";

      "trasnmission.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9091";
      "freshrss.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9576";
      "hassio.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8123";

      "stats.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:7590";
      "sync.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8384";

      "vikunja.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:3456";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    9443
  ];

  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@no-bull.sh";
    certs."no-bull.sh" = {
      domain = "*.no-bull.sh";
      group = "nginx";
      dnsResolver = "9.9.9.9#53";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets."cloudflare-dns-token.age".path;
    };
  };

  age.secrets."cloudflare-dns-token.age" = {
    owner = "acme";
    file = ../secrets/cloudflare-dns-token.age;
  };

  users.users.nginx.extraGroups = [ "acme" ];

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
    file = ../secrets/cloudflare-ddns.age;
  };

  boot = {
    initrd = {
      kernelModules = [ "kvm-intel" ];
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
      ];
    };
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev"; # "nodev" is used for UEFI
        efiSupport = true;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/d4cfc253-a622-46dd-a043-94f824a4ce6b";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/F77C-38CD";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/e9889b6a-4c29-46a7-b785-d509992fbb94"; }
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "25.11";
}
