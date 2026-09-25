{ vars,  ... }:

{
  resource = {
    authentik_provider_proxy.openbooks_provider = {
      name = "Provider for OpenBooks";
      external_host = "https://openbooks.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
    };
    authentik_application.openbooks = {
      name = "OpenBooks";
      slug = "openbooks";
      protocol_provider = "\${authentik_provider_proxy.openbooks_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/openbooks.png";
      meta_launch_url = "https://openbooks.${vars.traefik.domain}";
    };
    authentik_outpost_provider_attachment.openbooks_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.openbooks_provider.id}";
    };
  };
}
