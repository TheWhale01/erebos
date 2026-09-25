{ config, vars, ... }:

{
  virtualisation.oci-containers.containers.lidarr = {
    image = "lscr.io/linuxserver/lidarr:nightly";
    ports = [
      "${toString vars.lidarr.port}:8686"
    ];
    environment = {
      "PUID" = "1000";
      "PGID" = "100";
      "TZ" = "Europe/Paris";
    };
    volumes = [
      "/var/lib/lidarr:/config"
      "/data:/data"
    ];
  };
  services.traefik.dynamicConfigOptions.http = {
    services.lidarr.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.lidarr.settings.server.port}";
    }];
    routers = {
      lidarr = {
        rule = "Host(`lidarr.${vars.traefik.domain}`)";
        tls = true;
        service = "lidarr";
        entrypoints = "websecure";
        middlewares = [ "lidarr-auth" ];
        priority = 10;
      };
      lidarr-auth = {
        rule = "Host(`lidarr.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.lidarr-auth = {
      forwardAuth = {
        address = "http://${config.services.authentik-proxy.listenHTTP}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
