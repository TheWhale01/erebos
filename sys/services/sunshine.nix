{ ... }: {
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    settings = {
      sunshine_name = "erebos";
      port = 47989;
      address_family = "ipv6";
      max_bitrate = 0;
      stream_audio = true;
      upnp = false;
      ping_timeout = 10000;
      min_threads = 2;
    };
  };
}
