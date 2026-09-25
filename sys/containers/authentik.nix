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
      image = "authentik/server:${authentikVersion}";
      ports = [
        "${toString vars.authentik.port}:9000"
        "9300:9300"
        "3389:3389"
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
      image = "authentik/server:${authentikVersion}";
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
      image = "authentik/ldap:${authentikVersion}";
      environment = {
        AUTHENTIK_HOST = "http://127.0.0.1:9000";
        AUTHENTIK_INSECURE = "true";
      };
      environmentFiles = [
        config.age.secrets.authentik-ldap.path
      ];
      dependsOn = [ "authentik" ];
      extraOptions = [
        "--network=container:authentik"
      ];
    };
    authentik-proxy = {
      image = "authentik/proxy:${authentikVersion}";
      environment = {
        AUTHENTIK_HOST = "http://127.0.0.1:9000";
        AUTHENTIK_INSECURE = "true";
        AUTHENTIK_HOST_BROWSER = "https://authentik.${vars.traefik.domain}";
        # AUTHENTIK_LISTEN__METRICS = "127.0.0.1:9304";
        AUTHENTIK_LISTEN__HTTP = "127.0.0.1:9301";
        AUTHENTIK_LISTEN__HTTPS = "127.0.0.1:9444";
      };
      environmentFiles = [
        config.age.secrets.authentik-proxy.path
      ];
      dependsOn = [ "authentik" ];
      extraOptions = [
        "--network=container:authentik"
      ];
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.authentik.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString vars.authentik.port}";
    }];
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
