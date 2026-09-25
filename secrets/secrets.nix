let
  # SSH keys used to encrypt secrets
  erebos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQ/GL8RjU7lnxKb9YTzbdsO0O5KhMBwlbVwDZgY2LWb";
  erebos-stage = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINh/imYjgxInWiS5uKlTuabmuG+0VL2HWEfQ43NczK1O";
  hades = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9FADovUTXSn2694wMAViLnDJRn3TypRSzGHy3MNTo9";
  hades-stage = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM25SgGES1eclegLiVqRCNyhpK+k4GnFQJvw9p3o65Eb";

  prod = [ erebos hades ];
  stage = [ erebos-stage hades-stage ];
  shared = [ erebos erebos-stage hades hades-stage ];
in
{
  "shared/hades.age".publicKeys = shared;
  "shared/traefik.age".publicKeys = shared;
  "shared/gluetun.age".publicKeys = shared;
  "shared/grafana-secret.age".publicKeys = shared;
  "shared/transmission.age".publicKeys = shared;
  "shared/matrix/alertmanager-webhook.age".publicKeys = shared;
  "shared/matrix/erebot.age".publicKeys = shared;
  "shared/matrix/livekit.age".publicKeys = shared;
  "shared/authentik/smtp.age".publicKeys = shared;
  "shared/slskd.age".publicKeys = shared;

  "prod/actualbudget.age".publicKeys = prod;
  "prod/grafana.age".publicKeys = prod;
  "prod/homepage.age".publicKeys = prod;
  "prod/immich.age".publicKeys = prod;
  "prod/nextcloud.age".publicKeys = prod;
  "prod/vaultwarden.age".publicKeys = prod;
  "prod/terraform/authentik.age".publicKeys = prod;
  "prod/terraform/grafana.age".publicKeys = prod;
  "prod/terraform/jellyfin.age".publicKeys = prod;
  "prod/authentik/authentik.age".publicKeys = prod;
  "prod/authentik/ldap.age".publicKeys = prod;
  "prod/authentik/proxy.age".publicKeys = prod;
  "prod/matrix/appservice.age".publicKeys = prod;
  "prod/matrix/mas.age".publicKeys = prod;
  "prod/matrix/matrix.age".publicKeys = prod;

  "stage/actualbudget.age".publicKeys = stage;
  "stage/grafana.age".publicKeys = stage;
  "stage/homepage.age".publicKeys = stage;
  "stage/immich.age".publicKeys = stage;
  "stage/vaultwarden.age".publicKeys = stage;
  "stage/nextcloud.age".publicKeys = stage;
  "stage/terraform/authentik.age".publicKeys = stage;
  "stage/terraform/grafana.age".publicKeys = stage;
  "stage/terraform/jellyfin.age".publicKeys = stage;
  "stage/authentik/authentik.age".publicKeys = stage;
  "stage/authentik/ldap.age".publicKeys = stage;
  "stage/authentik/proxy.age".publicKeys = stage;
  "stage/matrix/appservice.age".publicKeys = stage;
  "stage/matrix/mas.age".publicKeys = stage;
  "stage/matrix/matrix.age".publicKeys = stage;
}
