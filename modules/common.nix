{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;

  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  users.users.james = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users.james = ../home-manager/james.nix;
  };

  environment.systemPackages = with pkgs; [
    # Editors
    vim

    curl
    git

    # Language Servers
    nil # Nix

    # Formatters
    nixfmt # Nix

    # Terminal utilities
    dust
    htop
    pstree

    # Network Utilities
    dig
  ];

  # Enable fish
  programs.fish.enable = true;

  # Use sudo-rs instead of sudo
  security.sudo-rs.enable = true;
  security.sudo.enable = false;

  # Enable automatic upgrades
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--print-build-logs"
    ];
    dates = "weekly";
    randomizedDelaySec = "45min";
    allowReboot = false; # Set to true if you want automatic reboots
  };

  # Enable automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
