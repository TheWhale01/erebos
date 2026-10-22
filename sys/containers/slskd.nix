{ vars, config, ... }:

{
  virtualisation.oci-containers.containers = {
    slskd = {
      image = "slskd/slskd:latest";
      user = "1000:100";
      volumes = [
        "/data:/data"
        "/var/lib/slskd:/app"
      ];
      ports = [
        "5030:5030/tcp"
        "5031:5031/tcp"
        "50300:50300/tcp"
      ];
      environment = {
        SLSKD_REMOTE_FILE_MANAGEMENT = "true";
        SLSKD_DOWNLOADS_DIR = "/data/downloads/music/slskd/complete";
        SLSKD_INCOMPLETE_DIR = "/data/downloads/music/slskd/incomplete";
        SLSKD_SHARED_DIR = "/data/Music";
        SLSKD_NO_AUTH = "true";
      };
      environmentFiles = [
        config.age.secrets.slskd.path
      ];
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.slskd.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.slskd.settings.web.port}";
    }];
    routers = {
      slskd = {
        rule = "Host(`slskd.${vars.traefik.domain}`)";
        tls = true;
        service = "slskd";
        entrypoints = "websecure";
        middlewares = [ "slskd-auth" ];
        priority = 10;
      };
      slskd-auth = {
        rule = "Host(`slskd.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.slskd-auth = {
      forwardAuth = {
        address = "http://127.0.0.1:${toString vars.authentik.proxy.port}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
}
