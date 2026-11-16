{ vars, ... }:

{
  resource = {
    authentik_provider_proxy.sunshine_provider = {
      name = "Provider for Sunshine";
      external_host = "https://sunshine.''${vars.traefik.domain}";
      authorization_flow = "''${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "''${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
    };
    authentik_application.sunshine = {
      name = "Sunshine";
      slug = "sunshine";
      protocol_provider = "''${authentik_provider_proxy.sunshine_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/sunshine.png";
      meta_launch_url = "https://sunshine.''${vars.traefik.domain}";
    };
    authentik_outpost_provider_attachment.sunshine_attachment = {
      outpost = "''${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "''${authentik_provider_proxy.sunshine_provider.id}";
    };
    authentik_group.sunshine_users = {
      name = "sunshine-users";
      users = [
        "''${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
    authentik_policy_binding.sunshine_policy = {
      target = "''${authentik_application.sunshine.uuid}";
      group = "''${authentik_group.sunshine_users.id}";
      order = 0;
    };
  };
}
