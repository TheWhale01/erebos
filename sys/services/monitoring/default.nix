{ ... }:

{
  imports = [
    ./grafana.nix
    ./loki.nix
    ./alloy.nix
    ./prometheus.nix
  ];
}
