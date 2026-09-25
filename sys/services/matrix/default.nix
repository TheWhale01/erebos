{ config, pkgs, vars, lib, ... }:

let
  mas-config = (import ./mas.nix { inherit config vars; }).config;
  yaml-format = pkgs.formats.yaml {};
in
{
  services.lk-jwt-service = {
    enable = true;
    port = 8004;
    livekitUrl = "wss://livekit.${vars.traefik.domain}";
    keyFile = config.age.secrets.livekit.path;
  };
  services.livekit = {
    enable = true;
    keyFile = config.age.secrets.livekit.path;
    settings = {
      port = 7880;
      rtc = {
        tcp_port = 7881;
        udp_port = 7882;
        port_range_start = 50000;
        port_range_end = 50050;
        use_external_ip = false;
        node_ip = "2a01:e0a:ede:b0e0:336f:5bb6:d67e:7309";
      };
    };
  };
  users.users.${vars.mas.user} = {
    isSystemUser = true;
    group = "${vars.mas.group}";
    home = "/var/lib/mas";
    createHome = true;
  };
  users.groups.${vars.mas.group} = {};
  systemd.services.mas = {
    description = "Matrix Authentication Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Type = "simple";
      User = "${vars.mas.user}";
      Group = "${vars.mas.group}";
      WorkingDirectory = "${config.users.users.mas.home}";
      ExecStart = "${pkgs.matrix-authentication-service}/bin/mas-cli server --config ${config.age.secrets.mas.path} --config ${yaml-format.generate "mas-config.yaml" mas-config}";
      ExecStartPre = lib.getExe (pkgs.writeShellScriptBin "generate-mas-rsa-key" ''
        if [ -f "${config.users.users.${vars.mas.user}.home}/keys/rsa.pem" ]; then
            echo "RSA Key pair already exists."
            exit 0
        fi
        ssh-keygen -t rsa -b 4096 -f "${config.users.users.${vars.mas.user}.home}/keys/rsa.pem" -N ""
      '');
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  services.matrix-synapse = {
    enable = true;
    extras = [ "oidc" ];
    extraConfigFiles = [
      config.age.secrets.matrix.path
    ];
    settings = {
      server_name = "matrix.${vars.traefik.domain}";
      public_baseurl = "https://${config.services.matrix-synapse.settings.server_name}";
      serve_server_wellknown = true;
      listeners = [{
        port = vars.matrix.port;
        bind_addresses = [ "127.0.0.1" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = false;
        }];
      }];
      app_service_config_files = [
        config.age.secrets.matrix-appservice.path
      ];
      extra_well_known_client_content = {
        "org.matrix.msc4143.rtc_foci" = [{
          type = "livekit";
          livekit_service_url = "https://livekit.${vars.traefik.domain}";
        }];
      };
      database = {
        name = "psycopg2";
        allow_unsafe_locale = true;
        args = {
          user = "${vars.matrix.user}";
          database = "matrix-synapse";
          host = "/run/postgresql";
        };
      };
      max_upload_size_mib = 500;
      url_preview_enabled = true;
      enable_registration = false;
      enable_metrics = false; # for now
      registration_shared_secret_path = "/var/lib/matrix-synapse/registration_secret";
      trusted_key_servers = [{
        server_name = "matrix.org";
      }];
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services = {
      matrix.loadBalancer.servers = [{ url = "http://127.0.0.1:${toString vars.matrix.port}"; }];
      mas.loadBalancer.servers = [{ url = "http://127.0.0.1:${toString vars.mas.port}"; }];
      livekit.loadBalancer.servers = [{ url = "http://127.0.0.1:${toString config.services.livekit.settings.port}"; }];
      lk-jwt.loadBalancer.servers = [{ url = "http://127.0.0.1:${toString config.services.lk-jwt-service.port}"; }];
    };
    routers = {
      matrix = {
        rule = "Host(`matrix.${vars.traefik.domain}`)";
        tls = true;
        service = "matrix";
        entrypoints = "websecure";
      };
      mas = {
        rule = "Host(`matrix-auth.${vars.traefik.domain}`)";
        tls = true;
        service = "mas";
        entrypoints = "websecure";
      };
      mas-compat = {
        rule = "Host(`matrix.${vars.traefik.domain}`) && PathRegexp(`^/_matrix/client/(r0|v3|v1|unstable)/(login|logout|refresh)`)";
        tls = true;
        service = "mas";
        entrypoints = "websecure";
      };
      livekit = {
        rule = "Host(`livekit.${vars.traefik.domain}`)";
        tls = true;
        service = "livekit";
        entrypoints = "websecure";
      };
      lk-jwt = {
        rule = "Host(`livekit.${vars.traefik.domain}`) && PathPrefix(`/sfu/`)";
        tls = true;
        service = "lk-jwt";
        entrypoints = "websecure";
      };
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ config.services.livekit.settings.rtc.tcp_port ];
    allowedUDPPorts = [ config.services.livekit.settings.rtc.udp_port ];
    allowedUDPPortRanges = [{ from = config.services.livekit.settings.rtc.port_range_start; to = config.services.livekit.settings.rtc.port_range_end; }];
  };
}
