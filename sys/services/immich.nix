{ config, vars, ... }:

{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    mediaLocation = "/data/Immich";
    settings = {
      newVersionCheck.enabled = true;
      oauth = {
        enabled = true;
        autoLaunch = true;
        autoRegister = true;
        buttonText = "Login with Authentik";
        issuerUrl = "https://authentik.${vars.traefik.domain}/application/o/immich/";
        scope = "openid email profile";
        storageLabelClaim = "preferred_username";
        clientId = "K9F0fVrJ7sIQrG9LeofyMkvnuwxvMQddQkoaavWh";
        clientSecret._secret = config.age.secrets.immich.path;
      };
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.immich.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.services.immich.port}";
    }];
    routers.immich = {
      rule = "Host(`immich.${vars.traefik.domain}`)";
      tls = true;
      service = "immich";
      entrypoints = "websecure";
    };
  };
}
