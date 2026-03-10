{
  config,
  lib,
  modulesPath,
  ...
}:
with lib;
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

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
}
