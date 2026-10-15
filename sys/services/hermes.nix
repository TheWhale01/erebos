{ config, vars, ... }:

{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    environmentFiles = [
      config.age.secrets.hermes.path
    ];
    settings = {
      model = {
        provider = "custom";
        base_url = "https://api.mistral.ai/v1";
        default = "mistral-medium-latest";
      };
      matrix = {
        require_mention = true;
        allowed_users = [
          "@whale:matrix.${vars.traefik.domain}"
        ];
      };
    };
  };
}
