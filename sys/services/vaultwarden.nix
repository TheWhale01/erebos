{ config, vars, ... }:

{
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SSO_ENABLED = true;
      SSO_CLIENT_ID = "wMiyW19hLA12AFBLR0bMKL16EFDA0pUahm6mDgW3";
      SSO_AUTHORITY = "https://authentik.${vars.traefik.domain}/application/o/vaultwarden/";
      SSO_SCOPES = "email profile offline_access";
      SSO_ALLOW_UNKNOWN_EMAIL_VERIFICATION = false;
      SSO_CLIENT_CACHE_EXPIRATION = 0;
      SSO_ONLY = true;
      SSO_SIGNUPS_MATCH_EMAIL = true;
      DATABASE_URL = "postgresql://%2Frun%2Fpostgresql/vaultwarden";
      DOMAIN = "https://vaultwarden.${vars.traefik.domain}";
    };
    dbBackend = "postgresql";
    environmentFile = config.age.secrets.vaultwarden.path;
  };
  services.traefik.dynamicConfigOptions.http = {
    services.vaultwarden.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
    }];
    routers.vaultwarden = {
      rule = "Host(`vaultwarden.${vars.traefik.domain}`)";
      tls = true;
      service = "vaultwarden";
      entrypoints = "websecure";
    };
  };
}
