{ vars, ... }:

{
  virtualisation.oci-containers.containers = {
    opengym-api = {
      image = "ghcr.io/duartesantos8/opengym-api:latest";
      volumes = [
        "/var/lib/opengym/api:/data"
      ];
      ports = [
        "${toString vars.opengym.web.port}:8080"
      ];
      environment = {
        RP_ID = "opengym.${vars.traefik.domain}";
        ORIGIN = "https://opengym.${vars.traefik.domain}";
        WEB_PORT = "${toString vars.opengym.web.port}";
        RP_NAME = "openGym";
        PORT = "3000";
        DATA_DIR = "/data";
        TRUST_PROXY = "1";
      };
    };
    opengym-web = {
      image = "ghcr.io/duartesantos8/opengym-web:latest";
      dependsOn = [ "opengym-api" ];
      environment = {
        NGINX_PORT = "8080";
        BACKEND = "127.0.0.1";
        PORT = "3000";
        RESOLVER = "1.1.1.1";
      };
      extraOptions = [ "--network=container:opengym-api" ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    services.opengym.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString vars.opengym.web.port}"; }
    ];
    routers.opengym = {
      rule = "Host(`opengym.${vars.traefik.domain}`)";
      tls = true;
      service = "opengym";
      entrypoints = [ "websecure" ];
      # middlewares = [ "authentik-forwardauth" ];
    };
  };
}
