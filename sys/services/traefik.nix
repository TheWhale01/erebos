{ config, vars, ... }:

{
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      accessLog.format = "json";
      log = {
        level = "DEBUG";
      };
      api = { };
      entryPoints.metrics.address = "127.0.0.1:8200";
      metrics.prometheus = {
        entryPoint = "metrics";
        addEntryPointsLabels = true;
        addRoutersLabels = true;
        addServicesLabels = true;
      };
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
          transport = {
            respondingTimeouts = {
              readTimeout = "0";
              writeTimeout = "0";
              idleTimeout = "0";
            };
          };
        };
      };
      certificatesResolvers = {
        "${vars.traefik.dns_provider}" = {
          acme = {
            email = "ard.rasp01@gmail.com";
            storage = "${config.services.traefik.dataDir}/acme.json";
            caserver = "https://acme-v02.api.letsencrypt.org/directory";
            dnsChallenge = {
              provider = "${vars.traefik.dns_provider}";
              resolvers = [
                "1.1.1.1:53"
                "8.8.8.8:53"
              ];
            };
          };
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        middlewares = {
          traefik-authentik-auth = {
            forwardAuth = {
              address = "http://${config.services.authentik-proxy.listenHTTP}/outpost.goauthentik.io/auth/traefik";
              trustForwardHeader = true;
              authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
            };
          };
        };
        routers = {
          traefik = {
            rule = "Host(`traefik.${vars.traefik.domain}`)";
            service = "api@internal";
            entrypoints = [ "websecure" ];
            middlewares = [ "traefik-authentik-auth" ];
            priority = 10;
            tls = {
              certResolver = "${vars.traefik.dns_provider}";
              domains = [
                {
                  main = "${vars.traefik.domain}";
                  sans = "*.${vars.traefik.domain}";
                }
              ];
            };
          };
          traefik-auth = {
            rule = "Host(`traefik.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
            tls = true;
            service = "authentik-proxy";
            entrypoints = [ "websecure" ];
            priority = 15;
          };
        };
      };
    };
  };
  systemd.services.traefik.serviceConfig = {
    EnvironmentFile = [ "${config.age.secrets.traefik.path}" ];
  };
}
