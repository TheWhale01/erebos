{ erebos, vars, ... }:

{
  locals.hermes_dashboard_env = vars.terraform.parseEnv "${erebos.config.age.secrets.hermes.path}";
  resource = {
    authentik_provider_proxy.hermes_dashboard_provider = {
      name = "Provider for Hermes Dashbaord";
      external_host = "https://hermes-dashboard.${vars.traefik.domain}";
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
      mode = "forward_single";
      basic_auth_enabled = true;
      basic_auth_username_attribute = "username";
      basic_auth_password_attribute = "password";
    };
    authentik_application.hermes_dashboard = {
      name = "Hermes Dashboard";
      slug = "hermes-dashboard";
      protocol_provider = "\${authentik_provider_proxy.hermes_dashboard_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/hermes.png";
      meta_launch_url = "https://hermes-dashboard.${vars.traefik.domain}";
    };
    authentik_group.hermes_dashboard_users = {
      name = "hermes_dashboard-users";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
      attributes = "\${jsonencode({
        username = local.hermes_dashboard_env[\"HERMES_DASHBOARD_BASIC_AUTH_USERNAME\"]
        password = local.hermes_dashboard_env[\"HERMES_DASHBOARD_BASIC_AUTH_PASSWORD\"]
      })}";
    };
    authentik_policy_binding.hermes_dashboard_policy = {
      target = "\${authentik_application.hermes_dashboard.uuid}";
      group = "\${authentik_group.hermes_dashboard_users.id}";
      order = 0;
    };
    authentik_outpost_provider_attachment.hermes_dashboard_attachment = {
      outpost = "\${authentik_outpost.proxy_outpost.id}";
      protocol_provider = "\${authentik_provider_proxy.hermes_dashboard_provider.id}";
    };
  };
}
