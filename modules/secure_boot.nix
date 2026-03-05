{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.host.secure-boot;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options.host.secure-boot.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sbctl ];

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      autoGenerateKeys.enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
