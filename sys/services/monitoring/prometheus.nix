{ config, vars, ... }:

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
    rules = [''
      groups:
      - name: systemd_services
        rules:
        - alert: ServiceCrashed
          expr: node_systemd_unit_state{name=~".+\\.service",state="failed"} == 1
          for: 1m
          labels:
            severity: critical
          annotations:
            summary: "Service crashed: {{ $labels.name }}"
            description: "{{ $labels.name }} entered failed state on {{ $labels.instance }}."
        - alert: ServiceOffline
          expr: node_systemd_unit_state{name=~"(matrix-synapse|mas|matrix-alertmanager|prometheus|prometheus-node-exporter|alertmanager|grafana|loki|alloy|traefik|nginx|postgresql|redis-immich|immich-server|vaultwarden|n8n|jellyfin|hermes-agent|netbird|sshd|podman-authentik.*|podman-nextcloud).*\\.service",type!~"oneshot.*",state="active"} == 0
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Service offline: {{ $labels.name }}"
            description: "Watched service {{ $labels.name }} not active for 5m on {{ $labels.instance }} (covers daily update-containers restarts)."
      - name: host_resources
        rules:
        - alert: DiskSpaceLow
          expr: node_filesystem_avail_bytes{mountpoint=~"/|/data",fstype!~"tmpfs|overlay|ramfs"} / node_filesystem_size_bytes{mountpoint=~"/|/data"} < 0.10
          for: 30m
          labels:
            severity: warning
          annotations:
            summary: "Disk low on {{ $labels.mountpoint }} ({{ $value | humanizePercentage }} free)"
        - alert: DiskSpaceCritical
          expr: node_filesystem_avail_bytes{mountpoint=~"/|/data",fstype!~"tmpfs|overlay|ramfs"} / node_filesystem_size_bytes{mountpoint=~"/|/data"} < 0.05
          for: 10m
          labels:
            severity: critical
          annotations:
            summary: "Disk CRITICAL on {{ $labels.mountpoint }} ({{ $value | humanizePercentage }} free)"
        - alert: FilesystemReadOnly
          expr: node_filesystem_readonly{fstype!~"tmpfs|overlay|ramfs"} == 1
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "{{ $labels.mountpoint }} remounted READ-ONLY (device: {{ $labels.device }})"
        - alert: MemoryLow
          expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.10
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Available memory <10% on {{ $labels.instance }}"
        - alert: CPUSaturated
          expr: 1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) > 0.90
          for: 15m
          labels:
            severity: warning
          annotations:
            summary: "CPU >90% sustained 15m on {{ $labels.instance }}"
        - alert: HostRebooted
          expr: changes(node_boot_time_seconds[10m]) > 0
          labels:
            severity: info
          annotations:
            summary: "{{ $labels.instance }} rebooted"
      - name: monitoring_self
        rules:
        - alert: ScrapeTargetDown
          expr: up == 0
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "Prometheus cannot scrape {{ $labels.job }} ({{ $labels.instance }})"
    ''];
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
    ];
    exporters = {
      node = {
        enable = true;
        port = 9100;
        listenAddress = "127.0.0.1";
        enabledCollectors = [ "systemd" "tcpstat" ];
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
    mention = true;
    tokenFile = config.age.secrets.erebot.path;
    secretFile = config.age.secrets.matrix-alertmanager-webhook.path;
    matrixRooms = [{
      receivers = [ "${config.services.prometheus.alertmanager.configuration.route.receiver}" ];
      roomId = "!C-EIAS89vRQV7k6yUk34TTqXDro5S3Xwx_sJidUW3Lk";
    }];
  };
}
