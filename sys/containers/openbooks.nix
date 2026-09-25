{ config, vars, ... }:

{
  virtualisation.oci-containers.containers."openbooks" = {
    image = "evanbuss/openbooks";
    volumes = [ "/data/Books/Books:/books" ];
    ports = [ "${toString vars.openbooks.port}:80" ];
    cmd = [
      "--persist"
      "--name=openbooks"
    ];
    environment = {
      PGID="100";
      PUID="1000";
    };
    extraOptions = [ "--name=openbooks" ];
  };
  services.traefik.dynamicConfigOptions.http = {
    services.openbooks.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString vars.openbooks.port}";
    }];
    routers = {
      openbooks = {
        rule = "Host(`openbooks.${vars.traefik.domain}`)";
        tls = true;
        service = "openbooks";
        entrypoints = "websecure";
        middlewares = [ "openbooks-auth" ];
        priority = 10;
      };
      openbooks-auth = {
        rule = "Host(`openbooks.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.openbooks-auth = {
      forwardAuth = {
        address = "http://${config.services.authentik-proxy.listenHTTP}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
