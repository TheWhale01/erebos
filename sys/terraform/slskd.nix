{ vars, ... }:

{
  resource = {
    authentik_provider_proxy.slskd_provider = {
      name = "Provider for slskd";
      external_host = "https://slskd.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
    };
    authentik_application.slskd = {
      name = "slskd";
      slug = "slskd";
      protocol_provider = "\${authentik_provider_proxy.slskd_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/slskd.png";
      meta_launch_url = "https://slskd.${vars.traefik.domain}";
    };
    authentik_outpost_provider_attachment.slskd_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.slskd_provider.id}";
    };
    authentik_group.slskd_users = {
      name = "slskd-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
  };
}
