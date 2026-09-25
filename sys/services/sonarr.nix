{ config, vars, ... }:

{
  services.sonarr = {
    enable = true;
    user = "hades";
    group = "users";
  };
  services.traefik.dynamicConfigOptions.http = {
    services.sonarr.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
    }];
    services.authentik-proxy.loadBalancer.servers = [{
      url = "http://${config.services.authentik-proxy.listenHTTP}";
    }];
    routers = {
      sonarr = {
        rule = "Host(`sonarr.${vars.traefik.domain}`)";
        tls = true;
        service = "sonarr";
        entrypoints = "websecure";
        middlewares = [ "sonarr-auth" ];
        priority = 10;
      };
      sonarr-auth = {
        rule = "Host(`sonarr.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.sonarr-auth = {
      forwardAuth = {
        address = "http://${config.services.authentik-proxy.listenHTTP}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
