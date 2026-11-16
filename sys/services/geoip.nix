{ config, ... }:

{
  services.geoipupdate = {
    enable = true;
    settings = {
      AccountID = 1445838;
      LicenseKey = config.age.secrets.maxmind.path;
      EditionIDs = [ "GeoLite2-City" ];
      DatabaseDirectory = "/var/lib/geoip";
    };
  };
}
