{ config, lib, ... }:
with lib;
let
  cfg = config.host.nfs;
in
{
  options.host.nfs = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    fileSystems = {
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
  };
}
