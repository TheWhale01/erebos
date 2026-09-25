{ config, vars, ... }:

{
  services.seerr = {
    enable = true;
  };
  services.traefik.dynamicConfigOptions.http = {
    services.seerr.loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${toString config.services.seerr.port}";
      }
    ];
    routers.seerr = {
      rule = "Host(`seerr.${vars.traefik.domain}`)";
      tls = true;
      service = "seerr";
      entrypoints = "websecure";
    };
  };
}
