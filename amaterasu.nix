{
  config,
  lib,
  modulesPath,
  ...
}:

# Hardware specific configuration for amaterasu
{
  imports = [
    ./desktop.nix
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
      luks.devices.cryptroot.device = "/dev/disk/by-label/NIX";
    };
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
    "/mnt/leviathan/games" = {
      device = "leviathan.jliu.lan:/volume1/Games";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    "/mnt/leviathan/files" = {
      device = "leviathan.jliu.lan:/volume1/Files";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    "/mnt/leviathan/media" = {
      device = "leviathan.jliu.lan:/volume1/Media";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
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
