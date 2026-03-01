{
  config,
  lib,
  modulesPath,
  ...
}:

# Hardware specific configuration for amaterasu
{
  imports = [
    ./modules/desktop.nix
    ./modules/nfs-shares.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "amaterasu";

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    };
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
      ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices.cryptroot = {
        device = "/dev/disk/by-label/NIX";
        preLVM = true;
        # SSD Optimizations
        bypassWorkqueues = true;
      };
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/NixVolGroup/root";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/NixVolGroup/home";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  swapDevices = [
    {
      device = "/dev/NixVolGroup/swap";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-label/NIX";
        label = "cryptroot";
      };
      priority = 2;
    }
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  system.stateVersion = "25.11";
}
