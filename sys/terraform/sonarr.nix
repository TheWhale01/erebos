{ vars, ... }:

{
  resource = {
    authentik_provider_proxy.sonarr_provider = {
      name = "Provider for Sonarr";
      external_host = "https://sonarr.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
    };
    authentik_application.sonarr = {
      name = "Sonarr";
      slug = "sonarr";
      protocol_provider = "\${authentik_provider_proxy.sonarr_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/sonarr.png";
      meta_launch_url = "https://sonarr.${vars.traefik.domain}";
    };
    authentik_group.sonarr_users = {
      name = "sonarr-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
    authentik_policy_binding.sonarr_policy = {
      target = "\${authentik_application.sonarr.uuid}";
      group = "\${authentik_group.sonarr_users.id}";
      order = 0;
    };
    authentik_outpost_provider_attachment.sonarr_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.sonarr_provider.id}";
    };
  };
}
