{ modulesPath, ... }:
# Hardware specific configuration for zeus
{
  imports = [
    ../modules/default.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  host = {
    desktop.enable = false;
    server.enable = true;
    nfs.enable = false;
  };

  networking.hostName = "zeus";

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev"; # "nodev" is used for UEFI
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
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

  system.stateVersion = "25.11";
}
