{
  config,
  lib,
  pkgs,
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

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  networking.hostName = "tsukuyomi";

  # Enable touchpad support
  services.libinput.enable = true;

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
        "8250_dw"
        "surface_aggregator"
        "surface_aggregator_registry"
        "surface_aggregator_hub"
        "surface_hid_core"
        "surface_hid"
        "intel_lpss"
        "intel_lpss_pci"
        "pinctrl_tigerlake"
      ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices.cryptroot.device = "/dev/disk/by-label/NIX";
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
      # For zram
      priority = 2;
    }
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "25.11";
}
