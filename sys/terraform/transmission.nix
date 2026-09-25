{ erebos, vars, ... }:

{
  locals.transmission_env = vars.terraform.parseEnv "${erebos.config.age.secrets.transmission.path}";
  resource = {
    authentik_provider_proxy.transmission_provider = {
      name = "Provider for Transmission";
      external_host = "https://transmission.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
      basic_auth_enabled = true;
      basic_auth_username_attribute = "username";
      basic_auth_password_attribute = "password";
    };
    authentik_application.transmission = {
      name = "Transmission";
      slug = "transmission";
      protocol_provider = "\${authentik_provider_proxy.transmission_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/transmission.png";
      meta_launch_url = "https://transmission.${vars.traefik.domain}";
    };
    authentik_group.transmission_users = {
      name = "transmission-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
      attributes = "\${jsonencode({
        username = local.transmission_env[\"USER\"]
        password = local.transmission_env[\"PASS\"]
      })}";
    };
    authentik_policy_binding.transmission_policy = {
      target = "\${authentik_application.transmission.uuid}";
      group = "\${authentik_group.transmission_users.id}";
      order = 0;
    };
    authentik_outpost_provider_attachment.transmission_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.transmission_provider.id}";
    };
  };
}
