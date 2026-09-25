{ pkgs, config, lib, vars, ... }:

{
  services.prowlarr = {
    enable = true;
  };
  systemd.services.prowlarr.preStart = lib.mkAfter ''
    CONFIG_FILE="${config.services.prowlarr.dataDir}/config.xml"

    if [ -f "$CONFIG_FILE" ]; then
      ${pkgs.gnused}/bin/sed -i 's/<AuthenticationMethod>.*<\/AuthenticationMethod>/<AuthenticationMethod>External<\/AuthenticationMethod>/g' "$CONFIG_FILE"
    fi
  '';
  services.traefik.dynamicConfigOptions.http = {
    services.prowlarr.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}";
    }];
    routers = {
      prowlarr = {
        rule = "Host(`prowlarr.${vars.traefik.domain}`)";
        tls = true;
        service = "prowlarr";
        entrypoints = "websecure";
        middlewares = [ "prowlarr-auth" ];
        priority = 10;
      };
      prowlarr-auth = {
        rule = "Host(`prowlarr.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.prowlarr-auth = {
      forwardAuth = {
        address = "http://${config.services.authentik-proxy.listenHTTP}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
