{ vars, ... }:

{
  resource = {
    authentik_provider_proxy.enableactual_provider = {
      name = "Provider for Enable Actual";
      external_host = "https://enableactual.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
    };
    authentik_application.enableactual = {
      name = "Enable Actual";
      slug = "enableactual";
      protocol_provider = "\${authentik_provider_proxy.enableactual_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/enableactual.png";
      meta_launch_url = "https://enableactual.${vars.traefik.domain}";
    };
    authentik_group.enableactual_users = {
      name = "enableactual-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
    authentik_policy_binding.enableactual_policy = {
      target = "\${authentik_application.enableactual.uuid}";
      group = "\${authentik_group.enableactual_users.id}";
      order = 0;
    };
    authentik_outpost_provider_attachment.enableactual_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.enableactual_provider.id}";
    };
  };
}
