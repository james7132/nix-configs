{ config, lib, modulesPath, ... }:
# Hardware specific configuration for loki
{
  imports = [
    ../modules/server.nix
    ../modules/nfs-shares.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "loki";

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."ns1.dns.internal" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:5380";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 9443 ];

  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };

  boot = {
    initrd = {
      kernelModules = [ "kvm-intel" ];
      availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
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

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e9889b6a-4c29-46a7-b785-d509992fbb94"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "25.11";
}
