{ config, vars, ... }:

{
  services.slskd = {
    enable = true;
    user = "hades";
    group = "users";
    settings = {
      directories = {
        downloads = "/data/downloads/music/slskd/complete";
        incomplete = "/data/downloads/music/slskd/incomplete";
      };
      shares = {
        directories = [
          "/data/Music"
        ];
      };
      web = {
        authentication = {
          disabled = true;
        };
      };
    };
    environmentFile = config.age.secrets.slskd.path;
  };
  services.traefik.dynamicConfigOptions.http = {
    services.slskd.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.slskd.settings.web.port}";
    }];
    services.authentik-proxy.loadBalancer.servers = [{
      url = "http://${config.services.authentik-proxy.listenHTTP}";
    }];
    routers = {
      slskd = {
        rule = "Host(`slskd.${vars.traefik.domain}`)";
        tls = true;
        service = "slskd";
        entrypoints = "websecure";
        middlewares = [ "slskd-auth" ];
        priority = 10;
      };
      slskd-auth = {
        rule = "Host(`slskd.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.slskd-auth = {
      forwardAuth = {
        address = "http://${config.services.authentik-proxy.listenHTTP}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
