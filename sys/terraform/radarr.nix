{ vars, ... }:

{
  resource = {
    authentik_provider_proxy.radarr_provider = {
      name = "Provider for Radarr";
      external_host = "https://radarr.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
    };
    authentik_application.radarr = {
      name = "Radarr";
      slug = "radarr";
      protocol_provider = "\${authentik_provider_proxy.radarr_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/radarr.png";
      meta_launch_url = "https://radarr.${vars.traefik.domain}";
    };
    authentik_group.radarr_users = {
      name = "radarr-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
    authentik_policy_binding.radarr_policy = {
      target = "\${authentik_application.radarr.uuid}";
      group = "\${authentik_group.radarr_users.id}";
      order = 0;
    };
    authentik_outpost_provider_attachment.radarr_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.radarr_provider.id}";
    };
  };
}
