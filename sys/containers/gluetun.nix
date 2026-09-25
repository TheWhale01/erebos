{ config, vars, ... }:

{
  virtualisation.oci-containers.containers.gluetun = {
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
      config.age.secrets.gluetun.path
      config.age.secrets.transmission.path
    ];
    volumes = [
      "gluetun:/gluetun"
    ];
  };
}
