{ vars, erebos, ... }:

{
  resource = {
    authentik_provider_oauth2.immich_provider = {
      name = "Provider for Immich";
      client_id = erebos.config.services.immich.settings.oauth.clientId;
      client_type = "confidential";
      sub_mode = "user_email";
      property_mappings = [
        "\${data.authentik_property_mapping_provider_scope.email.id}"
        "\${data.authentik_property_mapping_provider_scope.profile.id}"
        "\${data.authentik_property_mapping_provider_scope.openid.id}"
      ];
      signing_key = "\${data.authentik_certificate_key_pair.default.id}";
      grant_types = [
        "authorization_code"
        "implicit"
        "hybrid"
        "refresh_token"
        "client_credentials"
        "password"
      ];
      allowed_redirect_uris = [
        {
          matching_mode = "strict";
          redirect_uri_type = "authorization";
          url = "app.immich:///oauth-callback";
        }
        {
          matching_mode = "strict";
          redirect_uri_type = "authorization";
          url = "https://immich.${vars.traefik.domain}/auth/login";
        }
        {
          matching_mode = "strict";
          redirect_uri_type = "authorization";
          url = "https://immich.${vars.traefik.domain}/user-settings";
        }
      ];
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
    };
    authentik_application.immich = {
      name = "Immich";
      slug = "immich";
      protocol_provider = "\${authentik_provider_oauth2.immich_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/immich.png";
      meta_launch_url = "https://immich.${vars.traefik.domain}";
    };
  };
}
