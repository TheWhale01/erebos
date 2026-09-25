{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    maintainerr = {
      image = "ghcr.io/maintainerr/maintainerr:latest";
      volumes = [
        "maintainerr:/opt/data"
      ];
      environment = {
        TZ = "Europe/Paris";
      };
      user = "1000:100";
      ports = [ "${toString vars.maintainerr.port}:6246"];
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.maintainerr.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString vars.maintainerr.port}";
    }];
    routers = {
      maintainerr = {
        rule = "Host(`maintainerr.${vars.traefik.domain}`)";
        tls = true;
        service = "maintainerr";
        entrypoints = "websecure";
        middlewares = [ "maintainerr-auth" ];
        priority = 10;
      };
      maintainerr-auth = {
        rule = "Host(`maintainerr.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.maintainerr-auth = {
      forwardAuth = {
        address = "http://${config.services.authentik-proxy.listenHTTP}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
