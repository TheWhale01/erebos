{ config, vars, ... }:

{
  services.cleanerr = {
    enable = true;
    downloadDir = "/data/downloads";
    transmissionUrl = "http://127.0.0.1:${toString vars.transmission.port}";
    environmentFile = config.age.secrets.transmission.path;
    ignoredDirectories = [
      "${config.services.cleanerr.downloadDir}/aurral"
      "${config.services.cleanerr.downloadDir}/lidarr"
      "${config.services.cleanerr.downloadDir}/slskd"
    ];
  };
}
