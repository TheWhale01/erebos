let
  watchedServices = [
    "matrix-synapse"
    "mas"
    "matrix-alertmanager"
    "prometheus"
    "prometheus-node-exporter"
    "alertmanager"
    "grafana"
    "loki"
    "alloy"
    "traefik"
    "nginx"
    "postgresql"
    "redis-immich"
    "immich-server"
    "vaultwarden"
    "n8n"
    "jellyfin"
    "hermes-agent"
    "netbird"
    "sshd"
    "podman-.*"
    "homepage-dashboard"
    "seerr"
    "sonarr"
    "radarr"
    "prowlarr"
    "livekit"
  ];
in
{
  rules = {
    groups = [
      {
        name = "systemd_services";
        rules = [
          {
            alert = "ServiceCrashed";
            expr = ''node_systemd_unit_state{name=~".+\\.service",state="failed"} == 1'';
            for = "1m";
            labels.severity = "critical";
            annotations = {
              summary = "Service crashed: {{ $labels.name }}";
              description = "{{ $labels.name }} entered failed state on {{ $labels.instance }}.";
            };
          }
          {
            alert = "ServiceOffline";
            expr = ''node_systemd_unit_state{name=~"(${builtins.concatStringsSep "|" watchedServices}).*\\.service",type!~"oneshot.*",state="active"} == 0'';
            for = "5m";
            labels.severity = "warning";
            annotations = {
              summary = "Service offline: {{ $labels.name }}";
              description = "Watched service {{ $labels.name }} not active for 5m on {{ $labels.instance }} (covers daily update-containers restarts).";
            };
          }
        ];
      }
      {
        name = "host_resources";
        rules = [
          {
            alert = "DiskSpaceLow";
            expr = ''node_filesystem_avail_bytes{mountpoint=~"/|/data",fstype!~"tmpfs|overlay|ramfs"} / node_filesystem_size_bytes{mountpoint=~"/|/data"} < 0.10'';
            for = "30m";
            labels.severity = "warning";
            annotations.summary = "Disk low on {{ $labels.mountpoint }} ({{ $value | humanizePercentage }} free)";
          }
          {
            alert = "DiskSpaceCritical";
            expr = ''node_filesystem_avail_bytes{mountpoint=~"/|/data",fstype!~"tmpfs|overlay|ramfs"} / node_filesystem_size_bytes{mountpoint=~"/|/data"} < 0.05'';
            for = "10m";
            labels.severity = "critical";
            annotations.summary = "Disk CRITICAL on {{ $labels.mountpoint }} ({{ $value | humanizePercentage }} free)";
          }
          {
            alert = "FilesystemReadOnly";
            expr = ''node_filesystem_readonly{fstype!~"tmpfs|overlay|ramfs"} == 1'';
            for = "5m";
            labels.severity = "critical";
            annotations.summary = "{{ $labels.mountpoint }} remounted READ-ONLY (device: {{ $labels.device }})";
          }
          {
            alert = "MemoryLow";
            expr = ''node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.10'';
            for = "5m";
            labels.severity = "warning";
            annotations.summary = "Available memory <10% on {{ $labels.instance }}";
          }
          {
            alert = "CPUSaturated";
            expr = ''1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) > 0.90'';
            for = "15m";
            labels.severity = "warning";
            annotations.summary = "CPU >90% sustained 15m on {{ $labels.instance }}";
          }
          {
            alert = "HostRebooted";
            expr = ''changes(node_boot_time_seconds[10m]) > 0'';
            labels.severity = "info";
            annotations.summary = "{{ $labels.instance }} rebooted";
          }
        ];
      }
      {
        name = "monitoring_self";
        rules = [
          {
            alert = "ScrapeTargetDown";
            expr = ''up == 0'';
            for = "5m";
            labels.severity = "critical";
            annotations.summary = "Prometheus cannot scrape {{ $labels.job }} ({{ $labels.instance }})";
          }
          {
            alert = "AlloyConfigNotLoaded";
            expr = ''alloy_config_last_load_successful != 1'';
            for = "5m";
            labels.severity = "critical";
            annotations.summary = "Alloy last config load failed — pipeline frozen on stale config";
          }
          {
            alert = "LokiDroppingEntries";
            expr = ''increase(loki_write_dropped_entries_total[15m]) > 0'';
            for = "10m";
            labels.severity = "warning";
            annotations.summary = "Alloy dropping entries: {{ $value | humanize }} dropped in 15m";
          }
          {
            alert = "LogsPipelineStalled";
            expr = ''rate(loki_distributor_lines_received_total[15m]) == 0 unless on (instance) (up{job="loki"} == 0)'';
            for = "30m";
            labels.severity = "warning";
            annotations.summary = "No log lines received 30m while Loki up — journal->alloy->loki chain stalled";
          }
        ];
      }
    ];
  };
}
