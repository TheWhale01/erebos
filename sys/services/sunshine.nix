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
      middlewares = [ "sunshine-auth" ];
      priority = 10;
    };
    routers.sunshine-auth = {
      rule = "Host(`sunshine.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
      tls = true;
      service = "authentik-proxy";
      entrypoints = "websecure";
      priority = 15;
    };
    middlewares.sunshine-auth = {
      forwardAuth = {
        address = "http://127.0.0.1:${toString vars.authentik.proxy.port}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
