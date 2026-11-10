{ ... }:

{
  imports = [
    ./grafana.nix
    ./loki.nix
    ./alloy.nix
    ./prometheus
    ./geoip.nix
  ];
}
