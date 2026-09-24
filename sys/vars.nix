{ env, ... }:

{
  terraform = {
    parseEnv = path: "\${{ for line in compact(split(\"\\n\", file(\"${path}\"))) : split(\"=\", line)[0] => join(\"=\", slice(split(\"=\", line), 1, length(split(\"=\", line)))) }}";
  };
  traefik = {
    domain = if env == "prod" then "thewhale.fr" else "thewhale-${env}.fr";
    dns_provider = "cloudflare";
  };
  nextcloud = {
    port = 8881;
    office = {
      port = 9980;
    };
  };
  openbooks = {
    port = 8081;
  };
  maintainerr = {
    port = 6246;
  };
  transmission = {
    port = 9091;
    flood = {
      port = 3002;
    };
  };
  anaisbuche = {
    port = 8002;
  };
  jellyfin = {
    port = 8096;
  };
  authentik = {
    port = 9000;
  };
  matrix = {
    port = 8008;
    user = "matrix-synapse";
    group = "matrix-synapse";
  };
  mas = {
    user = "mas";
    group = "mas";
    domain = "matrix-auth";
    port = 8009;
  };
  actualbudget = {
    port = 5006;
  };
  enableactual = {
    port = 8003;
  };
  jwp = {
    port = 3005;
  };
  prometheus = {
    uid = "G0CojlhIuEI8Z0Rsyl5VGVP2qpzHW9Wy";
  };
  lidarr = {
    port = 8686;
  };
  slskd = {
    download_path = "/data/downloads/music/slskd";
  };
  sabnzbd = {
    port = 8080;
  };
}
