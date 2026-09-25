{ vars, erebos, ... }:

{
  resource = {
    authentik_property_mapping_provider_scope.vaultwarden_profile = {
      name = "Vaultwarden Profile";
      scope_name = "email";
      expression = "return {
  'email': request.user.email,
  'email_verified': True
}";
    };
    authentik_provider_oauth2.vaultwarden_provider = {
      name = "Provider for Vaultwarden";
      client_id = erebos.config.services.vaultwarden.config.SSO_CLIENT_ID;
      client_type = "confidential";
      signing_key = "\${data.authentik_certificate_key_pair.default.id}";
      sub_mode = "user_email";
      property_mappings = [
        "\${authentik_property_mapping_provider_scope.vaultwarden_profile.id}"
        "\${data.authentik_property_mapping_provider_scope.offline_access.id}"
        "\${data.authentik_property_mapping_provider_scope.profile.id}"
        "\${data.authentik_property_mapping_provider_scope.openid.id}"
      ];
      grant_types = [
        "authorization_code"
        "implicit"
        "hybrid"
        "refresh_token"
        "client_credentials"
        "password"
      ];
      allowed_redirect_uris = [{
        matching_mode = "strict";
        redirect_uri_type = "authorization";
        url = "https://vaultwarden.${vars.traefik.domain}/identity/connect/oidc-signin";
      }];

      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
    };
    authentik_application.vaultwarden = {
      name = "Vaultwarden";
      slug = "vaultwarden";
      protocol_provider = "\${authentik_provider_oauth2.vaultwarden_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/vaultwarden.png";
      meta_launch_url = "https://vaultwarden.${vars.traefik.domain}";
    };
  };
}
