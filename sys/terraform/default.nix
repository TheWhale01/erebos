{ ... }:

{
  terraform.required_providers = {
    authentik.source = "goauthentik/authentik";
    grafana.source = "grafana/grafana";
    http.source = "hashicorp/http";
  };

  imports = [
    # ./jellyfin.nix
    ./actualbudget.nix
    ./authentik.nix
    ./enableactual.nix
    ./grafana.nix
    ./immich.nix
    ./maintainerr.nix
    ./matrix.nix
    ./nextcloud.nix
    ./openbooks.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./traefik.nix
    ./transmission.nix
    ./vaultwarden.nix
    ./lidarr.nix
    ./slskd.nix
  ];
}
