{ config, ... }:
{
  services.bluesky-pds = {
    enable = true;
    pdsadmin.enable = true;
    environmentFiles = [ config.age.secrets."bluesky-pds.age".path ];
    settings = {
      PDS_PORT = 7070;
      PDS_HOSTNAME = "pds.no-bull.sh";
    };
  };

  age.secrets."bluesky-pds.age" = {
    owner = "pds";
    file = ../../secrets/bluesky-pds.age;
  };
}
