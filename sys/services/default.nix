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
    ./monitoring
    ./n8n.nix
    ./hermes.nix
  ];
}
