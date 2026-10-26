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
      dependsOn = [ "gluetun-slskd" ];
      environment = {
        SLSKD_REMOTE_FILE_MANAGEMENT = "true";
        SLSKD_DOWNLOADS_DIR = "/data/downloads/music/slskd/complete";
        SLSKD_INCOMPLETE_DIR = "/data/downloads/music/slskd/incomplete";
        SLSKD_SHARED_DIR = "/data/Music";
        SLSKD_NO_AUTH = "true";
        SLSKD_VPN = "true";
        SLSKD_VPN_PORT_FORWARDING = "true";
        SLSKD_VPN_GLUETUN_URL = "http://127.0.0.1:8000";
      };
      environmentFiles = [
        config.age.secrets.slskd.path
      ];
      extraOptions = [ "--network=container:gluetun-slskd" ];
    };
    gluetun-slskd = {
      image = "qmcgaw/gluetun:latest";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--device=/dev/net/tun:/dev/net/tun"
      ];
      ports = [
        "${toString vars.slskd.port}:5030"
      ];
      environment = {
        VPN_SERVICE_PROVIDER = "protonvpn";
        VPN_TYPE = "wireguard";
        SERVER_COUNTRIES = "Netherlands";
        PORT_FORWARD_ONLY = "on";
        VPN_PORT_FORWARDING = "on";
        VPN_PORT_FORWARDING_PROVIDER = "protonvpn";
        HTTP_CONTROL_SERVER_ADDRESS = "127.0.0.1:8000";
      };
      environmentFiles = [
        config.age.secrets.gluetun-slskd.path
      ];
      volumes = [
        "gluetun-slskd:/gluetun"
        "/tmp/gluetun-slskd:/tmp/gluetun"
      ];
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.slskd.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString vars.slskd.port}";
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
