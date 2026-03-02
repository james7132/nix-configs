{
  config,
  lib,
  modulesPath,
  ...
}:
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

    virtualHosts."ns1.no-bull.sh" = {
      useACMEHost = "no-bull.sh";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5380";
        proxyWebsockets = true;
      };
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
