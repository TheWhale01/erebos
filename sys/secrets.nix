{ config, vars, env, ... }:

{
  age = {
    secrets = {
      slskd = {
        file = ../secrets/shared/slskd.age;
        owner = "hades";
        group = "users";
        mode = "0400";
      };
      hades = {
        file = ../secrets/shared/hades.age;
        owner = "hades";
        group = "users";
        mode = "0400";
      };
      traefik = {
        file = ../secrets/shared/traefik.age;
        owner = "hades";
        group = "${config.services.traefik.group}";
        mode = "0440";
      };
      gluetun.file = ../secrets/shared/gluetun.age;
      grafana-secret = {
        file = ../secrets/shared/grafana-secret.age;
        owner = "grafana";
        mode = "0400";
      };
      transmission = {
        file = ../secrets/shared/transmission.age;
        owner = "hades";
        group = "users";
        mode = "0400";
      };
      matrix-alertmanager-webhook.file = ../secrets/shared/matrix/alertmanager-webhook.age;
      erebot.file = ../secrets/shared/matrix/erebot.age;
      livekit.file = ../secrets/shared/matrix/livekit.age;
      actualbudget = {
        file = ../secrets/${env}/actualbudget.age;
        owner = "hades";
        group = "users";
        mode = "0400";
      };
      grafana = {
        file = ../secrets/${env}/grafana.age;
        owner = "grafana";
        mode = "0400";
      };
      homepage.file = ../secrets/${env}/homepage.age;
      immich = {
        file = ../secrets/${env}/immich.age;
        owner = "${config.services.immich.user}";
        group = "${config.services.immich.group}";
        mode = "0400";
      };
      nextcloud.file = ../secrets/${env}/nextcloud.age;
      vaultwarden.file = ../secrets/${env}/vaultwarden.age;
      authentik-terraform = {
        file = ../secrets/${env}/terraform/authentik.age;
        owner = "hades";
        group = "users";
        mode = "0400";
      };
      grafana-terraform = {
        file = ../secrets/${env}/terraform/grafana.age;
        owner = "hades";
        group = "users";
        mode = "0400";
      };
      jellyfin-terraform = {
        file = ../secrets/${env}/terraform/jellyfin.age;
        owner = "hades";
        group = "users";
        mode = "0400";
      };
      authentik.file = ../secrets/${env}/authentik/authentik.age;
      authentik-smtp.file = ../secrets/shared/authentik/smtp.age;
      authentik-ldap.file = ../secrets/${env}/authentik/ldap.age;
      authentik-proxy.file = ../secrets/${env}/authentik/proxy.age;
      matrix-appservice = {
        file = ../secrets/${env}/matrix/appservice.age;
        owner = "${vars.matrix.user}";
        group = "${vars.matrix.group}";
        mode = "0400";
      };
      mas = {
        file = ../secrets/${env}/matrix/mas.age;
        owner = "${vars.mas.user}";
        group = "${vars.mas.group}";
        mode = "0400";
      };
      matrix = {
        file = ../secrets/${env}/matrix/matrix.age;
        owner = "${vars.matrix.user}";
        group = "${vars.matrix.group}";
        mode = "0400";
      };
    };
  };
}
