{ config, vars, ... }:

{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    environmentFiles = [
      config.age.secrets.hermes.path
    ];
    settings = {
      # dashboard = {
      #   public_url = "https://hermes-dashboard.${vars.traefik.domain}";
      # };
      model = {
        provider = "openrouter";
        default = "qwen/qwen3.8-flash";
      };
      matrix = {
        require_mention = true;
        allowed_users = [
          "@whale:matrix.${vars.traefik.domain}"
        ];
      };
    };
  };
  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Web Dashboard";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "hermes-agent.service" ];
    serviceConfig = {
      User = "${config.services.hermes-agent.user}";
      Group = "${config.services.hermes-agent.group}";
      EnvironmentFile = config.age.secrets.hermes.path;
      ExecStart = "/run/current-system/sw/bin/hermes dashboard --host 127.0.0.1 --port ${toString vars.hermes.dashboard.port} --no-open";
      Restart = "always";
      RestartSec = 10;
      RestartPreventExitStatus = 78;
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.hermes-dashboard.loadBalancer = {
      servers = [{
        url = "http://127.0.0.1:${toString vars.hermes.dashboard.port}";
      }];
      passHostHeader = false;
    };
    routers = {
      hermes-dashboard = {
        rule = "Host(`hermes-dashboard.${vars.traefik.domain}`)";
        tls = true;
        service = "hermes-dashboard";
        entrypoints = "websecure";
        middlewares = [ "hermes-dashboard-auth" ];
        priority = 10;
      };
      hermes-dashboard-auth = {
        rule = "Host(`hermes-dashboard.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.hermes-dashboard-auth = {
      forwardAuth = {
        address = "http://127.0.0.1:${toString vars.authentik.proxy.port}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
