{ config, vars, ... }:

{
  services.blog-builder = {
    enable = true;
    sites.blog-ideas = {
      nginx = {
        enable = true;
        index = "index.html";
        domain = "blog.${vars.traefik.domain}";
        port = 8883;
      };
      githubRepo = "https://github.com/TheWhale01/blog-ideas";
      settings = {
        theme = "catppuccin";
        url = "https://${config.services.blog-builder.sites.blog-ideas.nginx.domain}";
        name = "Whale's Blog";
      };
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.blog-builder.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.blog-builder.webhook.port}";
    }];
    services.blog.loadbalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.blog-builder.sites.blog-ideas.nginx.port}";
    }];
    routers.blog-builder = {
      rule = "Host(`blog.${vars.traefik.domain}`) && Path(`/webhook/blog-builder`)";
      tls = true;
      service = "blog-builder";
      entrypoints = "websecure";
    };
    routers.blog = {
      rule = "Host(`blog.${vars.traefik.domain}`)";
      tls = true;
      service = "blog";
      entrypoints = "websecure";
    };
  };
}
