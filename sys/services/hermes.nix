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
        provider = "openrouter";
        default = "qwen/qwen3.8-flash";
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
