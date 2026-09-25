{ config, vars, ... }:

{
  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "0.0.0.0";
    rules = [
      ''
        groups:
        - name: systemd_status
          rules:
          # Rule 1: The service crashed (entered 'failed' state)
          - alert: ServiceCrashed
            expr: node_systemd_unit_state{state="failed"} == 1
            for: 1m
            labels:
              severity: critical
            annotations:
              summary: "Service Crashed: {{ $labels.name }}"
              description: "The systemd service {{ $labels.name }} has entered a failed state on {{ $labels.instance }}."
          # Rule 2: The service is gracefully stopped, but shouldn't be
          - alert: ServiceOffline
            expr: node_systemd_unit_state{state="active"} == 0
            for: 3m
            labels:
              severity: warning
            annotations:
              summary: "Service Offline: {{ $labels.name }}"
              description: "The systemd service {{ $labels.name }} has been down for over 3 minutes."
      ''
    ];
    alertmanagers = [{
      static_configs = [{
        targets = [
          "127.0.0.1:${toString config.services.prometheus.alertmanager.port}"
        ];
      }];
    }];
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
          targets = [ "${config.services.authentik.worker.listenMetrics}" ];
        }];
      }
      {
        job_name = "traefik";
        static_configs = [{
          targets = [ "${config.services.traefik.staticConfigOptions.entryPoints.metrics.address}" ];
        }];
      }
    ];
    exporters = {
      node = {
        enable = true;
        port = 9100;
        listenAddress = "127.0.0.1";
        enabledCollectors = [ "systemd" "tcpstat" ];
        extraFlags = [
          "--collector.systemd.unit-include=(matrix-synapse|prometheus|grafana|loki|promtail|authentik|nginx|homepage-dashboard|immich|seerr|ollama|prowlarr|radarr|sonarr|traefik|vaultwarden|podman-.+).service"
          "--collector.systemd.unit-exclude=^podman-prune\\.service$"
        ];
      };
    };
    alertmanager = {
      enable = true;
      port = 9093;
      openFirewall = false;
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
            url = "http://127.0.0.1:${toString config.services.matrix-alertmanager.port}/alerts?secret=tDxIDjIVHSy45QAyu0VzJLFqrc3sW5ZG";
            send_resolved = true;
          }];
        }];
      };
    };
  };
  services.matrix-alertmanager = {
    enable = true;
    port = 3004;
    homeserverUrl = "https://matrix.${vars.traefik.domain}";
    matrixUser = "@${config.services.prometheus.alertmanager.configuration.route.receiver}:matrix.${vars.traefik.domain}";
    tokenFile = config.age.secrets.erebot.path;
    secretFile = config.age.secrets.matrix-alertmanager-webhook.path;
    matrixRooms = [{
      receivers = [ "${config.services.prometheus.alertmanager.configuration.route.receiver}" ];
      roomId = "!GntjVDhcqBQtGlwDnm:matrix.${vars.traefik.domain}";
    }];
  };
}
