{ vars, erebos, ... }:

{
  provider.grafana = {
    url = "https://grafana.${vars.traefik.domain}";
    auth = "\${file(\"/run/agenix/grafana-terraform\")}";
  };

  data.http.node_exporter.url = "https://grafana.com/api/dashboards/1860/revisions/latest/download";
  data.http.authentik.url = "https://grafana.com/api/dashboards/14837/revisions/latest/download";

  resource = {
    grafana_dashboard = {
      node_exporter.config_json = "\${data.http.node_exporter.response_body}";
      authentik.config_json = "\${replace(data.http.authentik.response_body, \"$${DS_PROMETHEUS}\", \"${vars.prometheus.uid}\")}";
    };
    authentik_provider_oauth2.grafana_provider = {
      name = "Provider for Grafana";
      client_id = erebos.config.services.grafana.settings."auth.generic_oauth".client_id;
      client_type = "confidential";
      grant_types = [
        "authorization_code"
        "refresh_token"
      ];
      property_mappings = [
        "\${data.authentik_property_mapping_provider_scope.email.id}"
        "\${data.authentik_property_mapping_provider_scope.profile.id}"
        "\${data.authentik_property_mapping_provider_scope.openid.id}"
      ];
      logout_uri = "https://grafana.${vars.traefik.domain}/logout";
      logout_method = "frontchannel";
      allowed_redirect_uris = [{
        matching_mode = "strict";
        redirect_uri_type = "authorization";
        url = "https://grafana.${vars.traefik.domain}/login/generic_oauth";
      }];
      authorization_flow = "\${data.authentik_flow.default_authorization_flow.id}";
      invalidation_flow = "\${data.authentik_flow.default_invalidation_flow.id}";
    };
    authentik_application.grafana = {
      name = "Grafana";
      slug = "grafana";
      protocol_provider = "\${authentik_provider_oauth2.grafana_provider.id}";
      meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/grafana.png";
      meta_launch_url = "https://grafana.${vars.traefik.domain}";
    };
    authentik_group.grafana_admins = {
      name = "grafana-admins";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
    authentik_group.grafana_editors = {
      name = "grafana-editors";
      is_superuser = false;
    };
    authentik_policy_binding.grafana_admins_policy = {
      target = "\${authentik_application.grafana.uuid}";
      group = "\${authentik_group.grafana_admins.id}";
      order = 0;
    };
    authentik_policy_binding.grafana_editors_policy = {
      target = "\${authentik_application.grafana.uuid}";
      group = "\${authentik_group.grafana_editors.id}";
      order = 1;
    };
  };
}
