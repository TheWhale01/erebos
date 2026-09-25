{ erebos, vars, ... }:

{
  locals.traefik_env = vars.terraform.parseEnv "${erebos.config.age.secrets.traefik.path}";
  resource = {
    authentik_provider_proxy.traefik_provider = {
      name = "Provider for Traefik";
      external_host = "https://traefik.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
      basic_auth_enabled = true;
      basic_auth_username_attribute = "username";
      basic_auth_password_attribute = "password";
    };
    authentik_application.traefik = {
      name = "Traefik";
      slug = "traefik";
      protocol_provider = "\${authentik_provider_proxy.traefik_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/traefik.png";
      meta_launch_url = "https://traefik.${vars.traefik.domain}";
    };
    authentik_group.traefik_users = {
      name = "traefik-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
      attributes = "\${jsonencode({
        username = local.traefik_env[\"USER\"]
        password = local.traefik_env[\"PASS\"]
      })}";
    };
    authentik_policy_binding.traefik_policy = {
      target = "\${authentik_application.traefik.uuid}";
      group = "\${authentik_group.traefik_users.id}";
      order = 0;
    };
    authentik_outpost_provider_attachment.traefik_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.traefik_provider.id}";
    };
  };
}
