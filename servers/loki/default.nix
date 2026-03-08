{
  config,
  lib,
  modulesPath,
  ...
}:
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
in
# Hardware specific configuration for loki
{
  imports = [
    ../../modules/default.nix
    ./acme.nix
    ./cloudflare-ddns.nix
    ./bluesky-pds.nix
    (modulesPath + "/installer/scan/not-detected.nix")
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

      "ns1.no-bull.sh" = mkProxyHost "http://127.0.0.1:5380";
      "ns2.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:5830";

      "pds.no-bull.sh" = mkIf config.services.bluesky-pds.enable (
        mkProxyHost "http://127.0.0.1:${builtins.toString config.services.bluesky-pds.settings.PDS_PORT}"
      );

      "immich.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:2283";
      "notify.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9072";

      "jellyfin.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8096";
      "radarr.no-bull.sh" = mkLocalProxyHost config.services.radarr;
      "sonarr.no-bull.sh" = mkLocalProxyHost config.services.sonarr;
      "lidarr.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:8686";
      "bazarr.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:6767";
      "prowlarr.no-bull.sh" = mkLocalProxyHost config.services.prowlarr;
      "komga.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9123";

      "transmission.no-bull.sh" = mkProxyHost "http://leviathan.no-bull.sh:9091";
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
  ];

  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    openFirewall = false;
    user = "sonarr";
    settings = {
      app = {
        theme = "dark";
      };
      server = {
        port = 8989;
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
    environmentFiles = [ config.age.secrets."sonarr.age".path ];
  };

  age.secrets."sonarr.age" = {
    owner = config.services.sonarr.user;
    file = ../../secrets/sonarr.age;
  };

  services.radarr = {
    enable = true;
    openFirewall = false;
    user = "radarr";
    settings = {
      app = {
        theme = "dark";
      };
      server = {
        port = 7878;
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
    environmentFiles = [ config.age.secrets."radarr.age".path ];
  };

  age.secrets."radarr.age" = {
    owner = config.services.radarr.user;
    file = ../../secrets/radarr.age;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = false;
    settings = {
      app = {
        theme = "dark";
      };
      server = {
        port = 9696;
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
    environmentFiles = [ config.age.secrets."prowlarr.age".path ];
  };

  age.secrets."prowlarr.age" = {
    owner = config.services.sonarr.user;
    file = ../../secrets/prowlarr.age;
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

  hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "25.11";
}
