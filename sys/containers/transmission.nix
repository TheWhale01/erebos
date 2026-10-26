{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    transmission = {
      image = "lscr.io/linuxserver/transmission:latest";
      extraOptions = [ "--network=container:gluetun-transmission" ];
      volumes = [
        "/var/lib/transmission:/config"
        "/data:/data"
      ];
      environmentFiles = [ config.age.secrets.transmission.path ];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Europe/Paris";
        LOG_LEVEL = "debug";
      };
      dependsOn = [ "gluetun-transmission" ];
    };
    flood = {
      hostname = "flood";
      user = "1000:100";
      image = "docker.io/jesec/flood:latest";
      cmd = [ "--port" "3001" "--allowedpath" "/data" ];
      environment = {
        HOME = "/config";
        FLOOD_OPTION_auth = "none";
        FLOOD_OPTION_trurl = "http://transmission:${toString vars.transmission.port}/transmission/rpc";
      };
      environmentFiles = [
        config.age.secrets.transmission.path
      ];
      volumes = [
        "/var/lib/flood:/config"
        "/data:/data"
      ];
      dependsOn = [ "transmission" ];
      extraOptions = [ "--network=container:gluetun-transmission" ];
    };
    transmission-port-sync = {
      image = "alpine:latest";
      dependsOn = [ "transmission" ];
      volumes = [
        "/tmp/gluetun-transmission:/tmp/gluetun:ro"
      ];
      environmentFiles = [
        config.age.secrets.transmission.path
      ];
      cmd = [
        "sh" "-c" ''
          apk update
          apk add --no-cache transmission-remote
          LAST_PORT=""
          sleep 10
          while true; do
            if [ -f /tmp/gluetun/forwarded_port ]; then
              CURRENT_PORT=$(cat /tmp/gluetun/forwarded_port)
              if [ -n "$CURRENT_PORT" ] && [ "$CURRENT_PORT" != "$LAST_PORT" ]; then
                echo "VPN port changed to $CURRENT_PORT, updating Transmission..."
                transmission-remote 127.0.0.1:9091 -n "$USER:$PASS" -p "$CURRENT_PORT"
                LAST_PORT="$CURRENT_PORT"
              fi
            fi
            sleep 1
          done
        ''
      ];
      extraOptions = [ "--network=container:gluetun-transmission" ];
    };
    gluetun-transmission = {
      image = "qmcgaw/gluetun:latest";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--device=/dev/net/tun:/dev/net/tun"
      ];
      ports = [
        "${toString vars.transmission.flood.port}:3001" # FLOOD
        "${toString vars.transmission.port}:9091" # TRANSMISSION
      ];
      environment = {
        VPN_PORT_FORWARDING_UP_COMMAND = ''
          /bin/sh -c 'command -v transmission-remote >/dev/null 2>&1 || (apk update && apk add transmission-remote); transmission-remote localhost:9091 -n "$USER:$PASS" -p {{PORT}}'
        '';
        VPN_SERVICE_PROVIDER = "protonvpn";
        VPN_TYPE = "wireguard";
        SERVER_COUNTRIES = "Switzerland";
        VPN_PORT_FORWARDING = "on";
        VPN_PORT_FORWARDING_PROVIDER = "protonvpn";
      };
      environmentFiles = [
        config.age.secrets.gluetun-transmission.path
        config.age.secrets.transmission.path
      ];
      volumes = [
        "gluetun-transmission:/gluetun"
        "/tmp/gluetun-transmission:/tmp/gluetun"
      ];
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.transmission.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString vars.transmission.flood.port}";
    }];
    routers = {
      transmission = {
        rule = "Host(`transmission.${vars.traefik.domain}`)";
        tls = true;
        service = "transmission";
        entrypoints = "websecure";
        middlewares = [ "transmission-auth" ];
        priority = 10;
      };
      transmission-auth = {
        rule = "Host(`transmission.${vars.traefik.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
        tls = true;
        service = "authentik-proxy";
        entrypoints = "websecure";
        priority = 15;
      };
    };
    middlewares.transmission-auth = {
      forwardAuth = {
        address = "http://127.0.0.1:${toString vars.authentik.proxy.port}/outpost.goauthentik.io/auth/traefik";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-authentik-username" "X-authentik-groups" "X-authentik-entitlements" "X-authentik-email" "X-authentik-name" "X-authentik-uid" "X-authentik-jwt" "X-authentik-meta-jwks" "X-authentik-meta-outpost" "X-authentik-meta-provider" "X-authentik-meta-app" "X-authentik-meta-version" "Authorization" ];
      };
    };
  };
  systemd.services."podman-transmission" = {
    after = [ "podman-gluetun-transmission.service" ];
    requires = [ "podman-gluetun-transmission.service" ];
    bindsTo = [ "podman-gluetun-transmission.service" ];
    partOf = [ "podman-gluetun-transmission.service" ];
  };
  systemd.services."podman-flood" = {
    after = [ "podman-transmission.service" ];
    requires = [ "podman-transmission.service" ];
    bindsTo = [ "podman-transmission.service" ];
    partOf = [ "podman-transmission.service" ];
  };
}
