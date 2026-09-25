{ config, vars, ... }:

{
  virtualisation.oci-containers.containers.actualbudget = {
    image = "actualbudget/actual-server:latest";
    ports = [ "${toString vars.actualbudget.port}:5006" ];
    volumes = [
      "actualbudget:/data"
    ];
    environment = {
      ACTUAL_OPENID_DISCOVERY_URL = "https://authentik.${vars.traefik.domain}/application/o/actual-budget/";
      ACTUAL_OPENID_CLIENT_ID = "AL0ItGV1fDxcVQY2nRXC5xQZBbaTPKzs2LXX7IgJ";
      ACTUAL_OPENID_SERVER_HOSTNAME = "https://actualbudget.${vars.traefik.domain}";
      ACTUAL_USER_CREATION_MODE = "login";
      ACTUAL_OPENID_ENFORCE = "true";
    };
    environmentFiles = [ config.age.secrets.actualbudget.path ];
  };
  virtualisation.oci-containers.containers.enableactual = {
    image = "2manyvcos/enable-actual";
    ports = [ "${toString vars.enableactual.port}:3000" ];
    environment = {
      SSL_ENABLED = "false";
      PUBLIC_URL = "https://enableactual.${vars.traefik.domain}";
    };
    volumes = [ "enableactual:/data" ];
  };
  services.traefik.dynamicConfigOptions.http = {
    services = {
      actualbudget.loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString vars.actualbudget.port}";
      }];
      enableactual.loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString vars.enableactual.port}";
      }];
    };
    routers = {
      actualbudget = {
        rule = "Host(`actualbudget.${vars.traefik.domain}`)";
        tls = true;
        service = "actualbudget";
        entrypoints = "websecure";
      };
      enableactual = {
        rule = "Host(`enableactual.${vars.traefik.domain}`)";
        tls = true;
        service = "enableactual";
        middlewares = [ "enableactual-auth" ];
        entrypoints = "websecure";
        priority = 10;
      };
      enableactual-auth = {
        rule = "Host(`enableactual.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.enableactual-auth = {
      forwardAuth = {
        address = "http://${config.services.authentik-proxy.listenHTTP}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
