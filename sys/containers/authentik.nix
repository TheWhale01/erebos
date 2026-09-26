{ config, vars, ... }:

let
  authentikVersion = "2026.8.1";
  env = {
    AUTHENTIK_DISABLE_STARTUP_ANALYTICS = "true";
    AUTHENTIK_AVATARS = "initials";
    AUTHENTIK_POSTGRESQL__HOST = "host.containers.internal";
    AUTHENTIK_POSTGRESQL__PORT = "5432";
    AUTHENTIK_POSTGRESQL__USER = "authentik";
    AUTHENTIK_POSTGRESQL__NAME = "authentik";
    AUTHENTIK_EMAIL__USERNAME = "resend";
    AUTHENTIK_EMAIL__HOST = "smtp.resend.com";
    AUTHENTIK_EMAIL__PORT = "465";
    AUTHENTIK_EMAIL__USE_SSL = "true";
    AUTHENTIK_EMAIL__USE_TLS = "false";
    AUTHENTIK_EMAIL__FROM = "authentik-no-reply@thewhale.fr";
  };
in
{
  virtualisation.oci-containers.containers = {
    authentik = {
      image = "ghcr.io/goauthentik/server:${authentikVersion}";
      ports = [
        "${toString vars.authentik.port}:9000"
        "${toString vars.authentik.metrics.port}:9300"
      ];
      environment = env;
      environmentFiles = [
        config.age.secrets.authentik-smtp.path
        config.age.secrets.authentik.path
      ];
      volumes = [
        "/var/lib/authentik/media:/media"
        "/var/lib/authentik/templates:/templates"
      ];
      cmd = [ "server" ];
    };
    authentik-worker = {
      image = "ghcr.io/goauthentik/server:${authentikVersion}";
      environment = env;
      environmentFiles = [
        config.age.secrets.authentik-smtp.path
        config.age.secrets.authentik.path
      ];
      volumes = [
        "/var/lib/authentik/media:/media"
        "/var/lib/authentik/templates:/templates"
        "/var/lib/authentik/certs:/certs"
      ];
      dependsOn = [ "authentik" ];
      cmd = [ "worker" ];
    };
    authentik-ldap = {
      image = "ghcr.io/goauthentik/ldap:${authentikVersion}";
      ports = [
        "${toString vars.authentik.ldap.port}:3389"
      ];
      environment = {
        AUTHENTIK_HOST = "http://authentik:9000";
        AUTHENTIK_INSECURE = "true";
      };
      environmentFiles = [
        config.age.secrets.authentik-ldap.path
      ];
      dependsOn = [ "authentik" ];
    };
    authentik-proxy = {
      image = "ghcr.io/goauthentik/proxy:${authentikVersion}";
      ports = [
        "${toString vars.authentik.proxy.port}:${toString vars.authentik.proxy.port}"
      ];
      environment = {
        AUTHENTIK_HOST = "http://authentik:9000";
        AUTHENTIK_INSECURE = "true";
        AUTHENTIK_HOST_BROWSER = "https://authentik.${vars.traefik.domain}";
        AUTHENTIK_LISTEN__HTTP = "0.0.0.0:${toString vars.authentik.proxy.port}";
        AUTHENTIK_LISTEN__HTTPS = "0.0.0.0:9444";
      };
      environmentFiles = [
        config.age.secrets.authentik-proxy.path
      ];
      dependsOn = [ "authentik" ];
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services = {
      authentik.loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString vars.authentik.port}";
      }];
      authentik-proxy.loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString vars.authentik.proxy.port}";
      }];
    };
    routers = {
      authentik = {
        rule = "Host(`authentik.${vars.traefik.domain}`)";
        tls = true;
        service = "authentik";
        entrypoints = "websecure";
      };
    };
  };
}
