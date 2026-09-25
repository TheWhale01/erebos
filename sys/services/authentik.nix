{ config, vars, ... }:

{
  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentik.path;
    settings = {
      disable_startup_analytics = true;
      avatars = "initials";
      listen.ldap = "127.0.0.1:3389";
      listen.ldaps = "127.0.0.1:6636";
      listen.metrics = [ "127.0.0.1:9300" ];
      postgresql = {
        host = "/run/postgresql";
        port = 5432;
        user = "authentik";
        name = "authentik";
      };
    };
  };
  services.authentik-ldap = {
    enable = true;
    environmentFile = config.age.secrets.authentik-ldap.path;
  };
  services.authentik-proxy = {
    enable = true;
    listenMetrics = "127.0.0.1:9303";
    listenHTTPS = "127.0.0.1:9004";
    listenHTTP = "127.0.0.1:9005";
    environmentFile = config.age.secrets.authentik-proxy.path;
  };
  systemd.services.authentik = {
    serviceConfig = {
      EnvironmentFile = [
        config.age.secrets.authentik-smtp.path
      ];
    };
  };
  systemd.services.authentik-worker = {
    serviceConfig = {
      EnvironmentFile = [
        config.age.secrets.authentik-smtp.path
      ];
    };
  };
  systemd.services.authentik-ldap = {
    environment = {
      AUTHENTIK_HOST = "http://127.0.0.1:${toString vars.authentik.port}";
      AUTHENTIK_INSECURE = "true";
    };
    serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };
  systemd.services.authentik-proxy = {
    environment = {
      AUTHENTIK_HOST = "http://127.0.0.1:${toString vars.authentik.port}";
      AUTHENTIK_INSECURE = "true";
      AUTHENTIK_HOST_BROWSER = "https://authentik.${vars.traefik.domain}";
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.authentik.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString vars.authentik.port}";
    }];
    routers.authentik = {
      rule = "Host(`authentik.${vars.traefik.domain}`)";
      tls = true;
      service = "authentik";
      entrypoints = "websecure";
    };
  };
}
