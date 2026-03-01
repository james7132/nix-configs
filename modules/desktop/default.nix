{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.host.desktop;
in
{
  options.host.desktop = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    laptop = mkOption {
      type = types.bool;
      default = false;
    };
    gaming = mkOption {
      type = types.bool;
      default = false;
    };
    development = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Enable sound.
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Enable touchpad support only on laptops
    services.libinput.enable = cfg.laptop;

    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-unwrapped"
        "steam-run"

        "nvidia-x11"
        "nvidia-settings"
        "nvidia-persistenced"
      ];

    environment.systemPackages = with pkgs; [
      # Niri related
      foot
      fuzzel
      swaylock
      mako
      swayidle
      swaybg
      waybar
      xwayland-satellite
      keepassxc

      # CLI utilities
      wl-clipboard
      handlr-regex

      # Web Browsers
      librewolf
      mullvad-browser
      tor-browser

      # Communications
      vesktop
      thunderbird
      signal-desktop

      # Media
      jellyfin-desktop
      mpv
      ncspot
    ];

    fonts.packages = with pkgs; [
      # Fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
    ];

    # Enable dynamically linked binaries
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
    ];

    programs.niri.enable = true;

    programs.steam = mkIf cfg.gaming {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = false; # Close ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    # Enable Protonmail Brdige
    services.protonmail-bridge.enable = true;

    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.swaylock = { };
  };
}
