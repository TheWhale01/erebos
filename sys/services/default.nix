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
    ./ollama.nix
    ./immich.nix
    ./cleanerr.nix
    ./matrix
    ./monitoring
    ./slskd.nix
    ./n8n.nix
    ./netbird.nix
  ];
}
