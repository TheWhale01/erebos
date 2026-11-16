{ config, vars, ... }:

{
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    settings = {
      sunshine_name = "erebos";
      port = 47989;
      address_family = "ipv6";
      max_bitrate = 0;
      stream_audio = true;
      upnp = false;
      ping_timeout = 10000;
      min_threads = 2;
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.sunshine.loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${toString config.services.sunshine.settings.port}";
      }
    ];
    routers.sunshine = {
      rule = "Host(`sunshine.${vars.traefik.domain}`)";
      tls = true;
      service = "sunshine";
      entrypoints = "websecure";
    };
  };
}
