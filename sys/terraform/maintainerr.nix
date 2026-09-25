{ vars,  ... }:

{
  resource = {
    authentik_provider_proxy.maintainerr_provider = {
      name = "Provider for Maintainerr";
      external_host = "https://maintainerr.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
    };
    authentik_application.maintainerr = {
      name = "Maintainerr";
      slug = "maintainerr";
      protocol_provider = "\${authentik_provider_proxy.maintainerr_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/maintainerr.png";
      meta_launch_url = "https://maintainerr.${vars.traefik.domain}";
    };
    authentik_group.maintainerr_users = {
      name = "maintainerr-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
    authentik_policy_binding.maintainerr_policy = {
      target = "\${authentik_application.maintainerr.uuid}";
      group = "\${authentik_group.maintainerr_users.id}";
      order = 0;
    };
    authentik_outpost_provider_attachment.maintainerr_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.maintainerr_provider.id}";
    };
  };
}
