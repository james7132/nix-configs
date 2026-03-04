let
  james = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvsHqk6FhbxJ7likL7zy+iUoR0tBlDocOyI++XsseI8 contact@no-bull.sh";
  users = [ james ];

  loki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINk1cIdhsUPBMK6+dFTfm3ASbT/NipdcYFqKcLY5OOYB";
  leviathan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoMx9wrjth4z7cG2N04AQncPq8vxDhodZcNmXc9WepN";
  apollo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcMCsSsIApzS9wp89pRAbUIW66L+xEpx9uHmRsGrQ3+";
  hourai = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQaMmPddnlsIc/DrefiiEFjfHitMhhjotV4qDjXpY6h";
  zeus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMc+lQaVLum4/X2MArU0GG7kiXj/4NDsc4pB3p7aO3i/";

  systems = [
    loki
    leviathan
    apollo
    hourai
    zeus
  ];
in
{
  "bluesky-pds.age" = {
    publicKeys = [
      james
      loki
    ];
    armor = true;
  };
  "cloudflare-dns-token.age" = {
    publicKeys = [ james ] ++ systems;
    armor = true;
  };
  "cloudflare-ddns.age" = {
    publicKeys = [ james ] ++ systems;
    armor = true;
  };
  "sonarr.age" = {
    publicKeys = [
      james
      loki
    ];
    armor = true;
  };
}
