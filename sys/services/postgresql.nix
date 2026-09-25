{ pkgs, ... }:

let
  users = [
    { name = "vaultwarden"; ensureDBOwnership = true; }
    { name = "nextcloud"; ensureDBOwnership = true; }
    { name = "authentik"; ensureDBOwnership = true; }
    { name = "matrix-synapse"; ensureDBOwnership = true; }
    { name = "mas"; ensureDBOwnership = true; }
  ];
  databases = [
    "vaultwarden"
    "nextcloud"
    "authentik"
    "matrix-synapse"
    "mas"
  ];
in
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all                 peer
      host  all all 127.0.0.1/32    scram-sha-256
      host  all all 10.88.0.0/16    scram-sha-256
      host  all all ::1/128         scram-sha-256
    '';
    settings = {
      min_wal_size = "80MB";
      max_wal_size = "2GB";
    };
    ensureUsers = users;
    ensureDatabases = databases;
  };
}
