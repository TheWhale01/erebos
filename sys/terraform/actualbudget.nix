{ vars, erebos, ... }:

{
  resource = {
    authentik_provider_oauth2.actualbudget_provider = {
      name = "Provider for Actual Budget";
      client_id = erebos.config.virtualisation.oci-containers.containers.actualbudget.environment.ACTUAL_OPENID_CLIENT_ID;
      client_type = "confidential";
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
      allowed_redirect_uris = [{
        matching_mode = "strict";
        redirect_uri_type = "authorization";
        url = "https://actualbudget.${vars.traefik.domain}/openid/callback";
      }];
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
    };
    authentik_application.actualbudget = {
      name = "Actual Budget";
      slug = "actual-budget";
      protocol_provider = "\${authentik_provider_oauth2.actualbudget_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/actual-budget.png";
      meta_launch_url = "https://actualbudget.${vars.traefik.domain}";
    };
  };
}
