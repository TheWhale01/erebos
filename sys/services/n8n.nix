{ vars, config, ... }:

{
  services.n8n = {
    enable = true;
  };
  services.traefik.dynamicConfigOptions.http = {
    services.n8n.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.n8n.environment.N8N_PORT}";
    }];
    routers.n8n = {
      rule = "Host(`n8n.${vars.traefik.domain}`)";
      tls = true;
      service = "n8n";
      entrypoints = "websecure";
    };
  };
}
