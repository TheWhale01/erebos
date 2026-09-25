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
    ./tailscale.nix
    ./slskd.nix
  ];
}
