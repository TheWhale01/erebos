{ vars, config, ... }:

{
  services.n8n = {
    enable = true;
    environment = {
      N8N_SSO_MANAGED_BY_ENV = "true";
      N8N_SSO_OIDC_LOGIN_ENABLED = "true";
      N8N_SSO_OIDC_CLIENT_ID = "EGCztj1jsOzL7AQ86m8tQWmnobLZJzi6pDUDDPKFeZajCW9DoI72gBmvcWLHhuGD";
      N8N_SSO_OIDC_DISCOVERY_ENDPOINT = "https://n8n.${vars.traefik.domain}/application/o/n8n/.well-known/openid-configuration";
      N8N_EDITOR_BASE_URL = "https://n8n.${vars.traefik.domain}";
    };
  };
  systemd.services.n8n.serviceConfig.EnvironmentFile = [
    config.age.secrets.n8n.path
  ];
  services.traefik.dynamicConfigOptions.http = {
    services.n8n.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.n8n.environment.N8N_PORT}";
    }];
    routers.n8n = {
      rule = "Host(`n8n.${vars.traefik.domain}`)";
      tls = true;
      service = "n8n";
      entrypoints = "websecure";
    };
  };
}
