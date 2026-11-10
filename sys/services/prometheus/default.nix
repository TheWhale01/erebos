{ config, vars, pkgs, ... }:

let
  prom_config = import ./config.nix;
  yaml_format = pkgs.formats.yaml {};
in
{
  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "127.0.0.1";
    alertmanagers = [{
      static_configs = [{
        targets = [
          "127.0.0.1:${toString config.services.prometheus.alertmanager.port}"
        ];
      }];
    }];
    ruleFiles = [
      (yaml_format.generate "prometheus-rules.yaml" prom_config.rules)
    ];
    scrapeConfigs = [
      {
        job_name = "prometheus";
        scrape_interval = "5s";
        static_configs = [{
          targets = [ "${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}" ];
        }];
      }
      {
        job_name = "node_exporter";
        static_configs = [{
          targets = [ "${config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "authentik";
        static_configs = [{
          targets = [ "127.0.0.1:${toString vars.authentik.metrics.port}" ];
        }];
      }
      {
        job_name = "traefik";
        static_configs = [{
          targets = [ "${config.services.traefik.staticConfigOptions.entryPoints.metrics.address}" ];
        }];
      }
      {
        job_name = "alloy";
        static_configs = [{
          targets = [ "127.0.0.1:${toString vars.alloy.port}" ];
        }];
      }
      {
        job_name = "loki";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}" ];
        }];
      }
      {
        job_name = "smartctl";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}" ];
        }];
      }
    ];
    exporters = {
      node = {
        enable = true;
        port = 9100;
        listenAddress = "127.0.0.1";
        enabledCollectors = [ "systemd" "tcpstat" ];
      };
      smartctl = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
    };
    alertmanager = {
      enable = true;
      port = 9093;
      openFirewall = false;
      environmentFile = config.age.secrets.prometheus.path;
      listenAddress = "127.0.0.1";
      configuration = {
        route = {
          receiver = "erebot";
          group_by = [ "alertname" "instance" ];
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "4h";
        };
        receivers = [{
          name = "${config.services.prometheus.alertmanager.configuration.route.receiver}";
          webhook_configs = [{
            url = "http://127.0.0.1:${toString config.services.matrix-alertmanager.port}/alerts?secret=$MATRIX_ALERT_WEBHOOK_SECRET";
            send_resolved = true;
          }];
        }];
      };
    };
  };
  services.matrix-alertmanager = {
    enable = true;
    port = 3004;
    homeserverUrl = "http://127.0.0.1:${toString vars.matrix.port}";
    matrixUser = "@${config.services.prometheus.alertmanager.configuration.route.receiver}:matrix.${vars.traefik.domain}";
    mention = false;
    tokenFile = config.age.secrets.erebot.path;
    secretFile = config.age.secrets.matrix-alertmanager-webhook.path;
    matrixRooms = [{
      receivers = [ "${config.services.prometheus.alertmanager.configuration.route.receiver}" ];
      roomId = "!C-EIAS89vRQV7k6yUk34TTqXDro5S3Xwx_sJidUW3Lk";
    }];
  };
  systemd.services.matrix-alertmanager = {
    environment = {
      ALERT_LINKS = "Alerts:{annotations.matrixNoLink}";
    };
  };
}
