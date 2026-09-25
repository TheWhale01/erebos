{ config, vars, ... }:

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.${vars.traefik.domain}";
        root_url = "https://${config.services.grafana.settings.server.domain}";
      };
      analytics.reporting_enabled = false;
      security.secret_key = config.age.secrets.grafana-secret.path;
      log = {
        level = "debug";
      };
      auth = {
        signout_redirect_url = "https://authentik.${vars.traefik.domain}/application/o/grafana/end-session/";
        oauth_auto_login = true;
      };
      "auth.generic_oauth" = {
        enabled = true;
        name = "authentik";
        client_id = "Hi2uiq5SViVynhibTRcaBuMGiqUNAt9sQQxZG8xq";
        scopes = "openid profile email";
        auth_url = "https://authentik.${vars.traefik.domain}/application/o/authorize/";
        token_url = "https://authentik.${vars.traefik.domain}/application/o/token/";
        api_url = "https://authentik.${vars.traefik.domain}/application/o/userinfo/";
        role_attribute_path = "contains(groups[*], 'grafana-admins') && 'Admin' || contains(groups[*], 'grafana-editors') && 'Editor' || 'Viewer'";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          uid = "${vars.prometheus.uid}";
          isDefault = true;
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://${config.services.loki.configuration.common.instance_addr}:${toString config.services.loki.configuration.server.http_listen_port}";
        }
      ];
    };
  };
  systemd.services.grafana.serviceConfig.EnvironmentFile = [
    config.age.secrets.grafana.path
  ];
  services.traefik.dynamicConfigOptions.http = {
    services.grafana.loadBalancer.servers = [{
      url = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
    }];
    routers.grafana = {
      rule = "Host(`grafana.${vars.traefik.domain}`)";
      tls = true;
      service = "grafana";
      entrypoints = "websecure";
    };
  };
}
