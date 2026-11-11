{ ... }:

{
  imports = [
    ./homepage.nix
    ./jellyfin/jellyfin.nix
    ./seerr.nix
    ./nginx.nix
    ./openssh.nix
    ./postgresql.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./traefik.nix
    ./vaultwarden.nix
    ./blog.nix
    ./llamacpp.nix
    ./immich.nix
    ./cleanerr.nix
    ./matrix
    ./n8n.nix
    ./hermes.nix
    ./fail2ban.nix
    ./smartd.nix
    ./grafana.nix
    ./loki.nix
    ./alloy.nix
    ./prometheus
    ./geoip.nix
    ./fwupd.nix
    ./sunshine.nix
  ];
}
