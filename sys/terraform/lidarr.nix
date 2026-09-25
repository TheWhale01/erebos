{ vars,  ... }:

{
  resource = {
    authentik_provider_proxy.lidarr_provider = {
      name = "Provider for Lidarr";
      external_host = "https://lidarr.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
    };
    authentik_application.lidarr = {
      name = "Lidarr";
      slug = "lidarr";
      protocol_provider = "\${authentik_provider_proxy.lidarr_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/lidarr.png";
      meta_launch_url = "https://lidarr.${vars.traefik.domain}";
    };
    authentik_outpost_provider_attachment.lidarr_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.lidarr_provider.id}";
    };
    authentik_group.lidarr_users = {
      name = "lidarr-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
    authentik_policy_binding.lidarr_policy = {
      target = "\${authentik_application.lidarr.uuid}";
      group = "\${authentik_group.lidarr_users.id}";
      order = 0;
    };
  };
}
