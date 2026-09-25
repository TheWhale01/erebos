{ vars,  ... }:

{
  resource = {
    authentik_property_mapping_provider_scope.nextcloud_profile= {
      name = "Nextcloud Profile";
      scope_name = "nextcloud";
      expression = "
groups = [group.name for group in user.groups.all()]
if user.is_superuser and 'admin' not in groups:
  groups.append('admin')
return {
  'name': request.user.name,
  'groups': groups,
  'quota': user.group_attributes().get('nextcloud_quota', None),
  'user_id': user.attributes.get('nextcloud_user_id', request.user.username),
}";
    };
    authentik_provider_oauth2.nextcloud_provider = {
      name = "Provider for Nextcloud";
      client_id = "jdMwnqB1FZ0tho8cJZssJGcdXgO6UYWqGxc6Lxkx";
      client_type = "confidential";
      property_mappings = [ "\${authentik_property_mapping_provider_scope.nextcloud_profile.id}" ];
      logout_uri = "https://nextcloud.${vars.traefik.domain}/index.php/apps/user_oidc/backchannel-logout/authentik";
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
        url = "https://nextcloud.${vars.traefik.domain}/index.php/apps/user_oidc/code";
      }];
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
    };
    authentik_application.nextcloud = {
      name = "Nextcloud";
      slug = "nextcloud";
      protocol_provider = "\${authentik_provider_oauth2.nextcloud_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/nextcloud.png";
      meta_launch_url = "https://nextcloud.${vars.traefik.domain}";
    };
  };
}
