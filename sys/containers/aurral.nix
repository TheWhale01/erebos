{ vars, config, ... }:

{
  virtualisation.oci-containers.containers.aurral = {
    image = "ghcr.io/lklynet/aurral:latest";
    ports = [
      "${toString vars.aurral.port}:3001"
    ];
    environment = {
      PUID = "1000";
      PGID = "100";
      OIDC_ENABLED = "true";
      OIDC_ISSUER = "https://authentik.${vars.traefik.domain}/application/o/immich/";
      OIDC_CLIENT_ID = "i257FTVY7cQStZqDJZ8DLWcCChWxjlaH5cgcWY6uTwuVCmHBRX";
      OIDC_REDIRECT_URI = "https://aurral.${vars.traefik.domain}/sso/callback";
    };
    environmentFiles = [
      config.age.secrets.aurral.file
    ];
    volumes = [
      "/var/lib/aurral:/config"
      "/data:/data"
    ];
  };
  services.traefik.dynamicConfigOptions.http = {
    services.aurral.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString vars.aurral.port}";
    }];
    routers = {
      aurral = {
        rule = "Host(`aurral.${vars.traefik.domain}`)";
        tls = true;
        service = "aurral";
        entrypoints = "websecure";
      };
    };
  };
}
