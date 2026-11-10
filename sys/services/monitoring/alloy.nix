{ config, pkgs, ... }:

let
  alloyConf = pkgs.writeText "config.alloy" ''
    loki.write "default" {
      endpoint {
        url = "http://${config.services.loki.configuration.common.instance_addr}:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
      }
    }

    // Promote __journal__systemd_unit (internal label, dropped by default) to a real `unit` label.
    discovery.relabel "journal" {
      targets = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.source.journal "system" {
      path          = "/var/log/journal"
      max_age       = "12h"
      labels = {
        job  = "systemd-journal",
        host = "127.0.0.1",
      }
      relabel_rules = discovery.relabel.journal.rules
      forward_to    = [loki.process.system.receiver]
    }

    loki.process "system" {
      forward_to = [loki.write.default.receiver]

      // Traefik JSON access logs -> structured labels (accessLog.format=json is set in traefik.nix)
      stage.match {
        selector = "{unit=\"traefik.service\"}"

        stage.json {
          expressions = {
            status       = "DownstreamStatus",
            request_path = "request_path",
            client_ip    = "ClientHost",
            method       = "RequestMethod",
          }
        }

        stage.labels {
          values = {
            status       = "",
            request_path = "",
            method       = "",
          }
        }
      }
    }
  '';
in
{
  services.alloy = {
    enable = true;
    configPath = alloyConf;
  };
}
