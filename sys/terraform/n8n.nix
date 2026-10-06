{ vars, erebos, ... }:

{
  resource = {
    authentik_provider_oauth2.n8n_provider = {
      name = "Provider for n8n";
      client_id = erebos.config.services.n8n.environment.N8N_SSO_OIDC_CLIENT_ID;
      client_type = "confidential";
      signing_key = "\${data.authentik_certificate_key_pair.default.id}";
      sub_mode = "user_username";
      property_mappings = [
        "\${data.authentik_property_mapping_provider_scope.email.id}"
        "\${data.authentik_property_mapping_provider_scope.profile.id}"
        "\${data.authentik_property_mapping_provider_scope.openid.id}"
      ];
      grant_types = [
        "authorization_code"
        "refresh_token"
      ];
      allowed_redirect_uris = [{
        matching_mode = "strict";
        redirect_uri_type = "authorization";
        url = "https://n8n.${vars.traefik.domain}/rest/sso/oidc/callback";
      }];
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
    };
    authentik_group.n8n_owners = {
      name = "n8n-owners";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
    authentik_group.n8n_users = {
      name = "n8n-users";
      users = [];
      is_superuser = false;
    };
    authentik_application.n8n = {
      name = "n8n";
      slug = "n8n";
      protocol_provider = "\${authentik_provider_oauth2.n8n_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/n8n.png";
      meta_launch_url = "https://n8n.${vars.traefik.domain}";
    };
    authentik_policy_binding.n8n_owners_policy = {
      target = "\${authentik_application.n8n.uuid}";
      group = "\${authentik_group.n8n_owners.id}";
      order = 0;
    };
    authentik_policy_binding.n8n_users_policy = {
      target = "\${authentik_application.n8n.uuid}";
      group = "\${authentik_group.n8n_users.id}";
      order = 1;
    };
  };
}
