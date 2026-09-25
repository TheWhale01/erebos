{ vars, ... }:

{
  resource = {
    authentik_provider_proxy.prowlarr_provider = {
      name = "Provider for Prowlarr";
      external_host = "https://prowlarr.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
    };
    authentik_application.prowlarr = {
      name = "Prowlarr";
      slug = "prowlarr";
      protocol_provider = "\${authentik_provider_proxy.prowlarr_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/prowlarr.png";
      meta_launch_url = "https://prowlarr.${vars.traefik.domain}";
    };
    authentik_group.prowlarr_users = {
      name = "prowlarr-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
    authentik_policy_binding.prowlarr_policy = {
      target = "\${authentik_application.prowlarr.uuid}";
      group = "\${authentik_group.prowlarr_users.id}";
      order = 0;
    };
    authentik_outpost_provider_attachment.prowlarr_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.prowlarr_provider.id}";
    };
  };
}
