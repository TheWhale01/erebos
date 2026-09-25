{ vars, ... }:

let
  filename = "portfolio_anais.pdf";
in
{
  services.nginx = {
    enable = true;
    virtualHosts."anaisbuche.thewhale.fr" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = vars.anaisbuche.port;
        }
      ];
      root = "/var/www/pdf";
      locations."/" = {
        tryFiles = "/${filename} =404";
        extraConfig = ''
          add_header Content-Type application/pdf;
        '';
      };
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.anaisbuche.loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${toString vars.anaisbuche.port}";
      }
    ];
    routers.anaisbuche = {
      rule = "Host(`anaisbuche.${vars.traefik.domain}`)";
      tls = true;
      service = "anaisbuche";
      entrypoints = "websecure";
    };
  };
}
