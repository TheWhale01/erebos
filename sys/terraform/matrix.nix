{ vars,  ... }:

{
  resource = {
    authentik_provider_oauth2.matrix_provider = {
      name = "Provider for Matrix";
      client_id = "cRxigyqzs0RjwvKpoEouTYrIcWo2Z7CUkiwAL6D5";
      client_type = "confidential";
      signing_key = "\${data.authentik_certificate_key_pair.default.id}";
      sub_mode = "user_username";
      property_mappings = [
        "\${data.authentik_property_mapping_provider_scope.email.id}"
        "\${data.authentik_property_mapping_provider_scope.profile.id}"
        "\${data.authentik_property_mapping_provider_scope.openid.id}"
      ];
      logout_uri = "https://matrix-auth.${vars.traefik.domain}/upstream/backchannel-logout/01KKA1N26ZPXXESCWRZEKV6DG0";
      grant_types = [
        "authorization_code"
        "refresh_token"
      ];
      allowed_redirect_uris = [{
        matching_mode = "strict";
        redirect_uri_type = "authorization";
        url = "https://matrix-auth.${vars.traefik.domain}/upstream/callback/01KKA1N26ZPXXESCWRZEKV6DG0";
      }];
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
    };
    authentik_application.matrix = {
      name = "Matrix";
      slug = "matrix";
      protocol_provider = "\${authentik_provider_oauth2.matrix_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/matrix.png";
      meta_launch_url = "https://matrix.${vars.traefik.domain}";
    };
  };
}
