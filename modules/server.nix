{ ... }:
{
  imports = [
    ./common.nix
  ];

  services.openssh = {
    enable = true;
    ports = [ 2626 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "james" ];
    };
  };

  users.users.james = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvsHqk6FhbxJ7likL7zy+iUoR0tBlDocOyI++XsseI8 contact@no-bull.sh"
    ];
  };
}
