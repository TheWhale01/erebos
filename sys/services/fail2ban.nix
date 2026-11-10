{ ... }:

{
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "10.88.0.0/16"          # podman
      "10.2.0.0/16"           # gluetun
      "192.168.1.0/24"        # LAN
    ];
    bantime-increment = {
      enable = true;
      maxtime = "48h";
      rndtime = "1h";
    };
    jails.sshd.settings = {
      maxretry = 5;
      findtime = "10m";
      bantime  = "1h";
    };
  };
}
