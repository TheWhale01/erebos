{ config, vars, ... }:

{
  config = {
    http = {
      public_base = "https://${vars.mas.domain}.${vars.traefik.domain}/";
      issuer = "https://${vars.mas.domain}.${vars.traefik.domain}/";
      listeners = [{
        name = "web";
        binds = [{ address = "127.0.0.1:${toString vars.mas.port}"; }];
        resources = [
          { name = "discovery"; }
          { name = "human"; }
          { name = "oauth"; }
          { name = "compat"; }
          { name = "assets"; }
          { name = "graphql"; }
        ];
      }];
    };
    database = {
      uri = "postgresql:///mas?host=/run/postgresql";
    };
    matrix = {
      kind = "synapse";
      homeserver = "${config.services.matrix-synapse.settings.server_name}";
      endpoint = "http://127.0.0.1:${toString vars.matrix.port}";
    };
    passwords = {
      enabled = false;
    };
    secrets = {
      keys = [{
        key_file = "${config.users.users.${vars.mas.user}.home}/keys/rsa.pem";
        kid = "mas-rsa-key-1";
      }];
    };
  };
}
