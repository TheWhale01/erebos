{ config, vars, ... }:

{
  services.homepage-dashboard = {
    enable = true;
    environmentFiles = [
      config.age.secrets.homepage.path
    ];
    allowedHosts = "${vars.traefik.domain}";
    widgets = [
      {
        resources = {
          cpu = true;
          disk = "/";
          memory = true;
        };
      }
      {
        datetime = {
          text_size = "sm";
          locale = "fr";
          format = {
            dateStyle = "long";
            timeStyle = "short";
          };
        };
      }
    ];
    services = [
      {
        Streaming = [
          {
            Jellyfin = {
              icon = "jellyfin.png";
              href = "https://jellyfin.${vars.traefik.domain}";
              description = "The Free Software Media System";
              widget = {
                type = "jellyfin";
                url = "http://127.0.0.1:${toString vars.jellyfin.port}";
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                enableBlocks = true;
                enableNowPlaying = true;
                enableUser = true;
                showEpisodeNumber = true;
                expandOneStreamToTwoRows = false;
              };
            };
          }
          {
            Seerr = {
              icon = "seerr.png";
              href = "https://seerr.${vars.traefik.domain}";
              description = "Open-source media request and discovery manager for Jellyfin, Plex, and Emby";
              widget = {
                type = "seerr";
                url = "http://127.0.0.1:${toString config.services.seerr.port}";
                key = "{{HOMEPAGE_VAR_SEERR_KEY}}";
              };
            };
          }
          {
            Immich = {
              icon = "immich.png";
              href = "https://immich.${vars.traefik.domain}";
              description = "Self-hosted photo and video management solution";
              widget = {
                type = "immich";
                url = "http://127.0.0.1:${toString config.services.immich.port}";
                key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                version = 2;
              };
            };
          }
        ];
      }
      {
        "Request Utilities" = [
          {
            Radarr = {
              icon = "radarr.png";
              description = "Movie organizer/manager for usenet and torrent users";
              href = "https://radarr.${vars.traefik.domain}";
              widget = {
                type = "radarr";
                url = "http://127.0.0.1:${toString config.services.radarr.settings.server.port}";
                key = "{{HOMEPAGE_VAR_RADARR}}";
                enableQueue = true;
              };
            };
          }
          {
            Sonarr = {
              icon = "sonarr.png";
              description = "Smart PVR for newsgroup and bittorrent users";
              href = "https://sonarr.${vars.traefik.domain}";
              widget = {
                type = "sonarr";
                url = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
                key = "{{HOMEPAGE_VAR_SONARR}}";
                enableQueue = true;
              };
            };
          }
          {
            Prowlarr = {
              icon = "prowlarr.png";
              description = "indexer manager/proxy built on the popular *arr stack";
              href = "https://prowlarr.${vars.traefik.domain}";
              widget = {
                type = "prowlarr";
                url = "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}";
                key = "{{HOMEPAGE_VAR_PROWLARR}}";
              };
            };
          }
          {
            Transmission = {
              icon = "transmission.png";
              description = "BitTorrent client";
              href = "https://transmission.${vars.traefik.domain}";
              widget = {
                type = "transmission";
                url = "http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
                username = "{{HOMEPAGE_VAR_TRANSMISSION_USERNAME}}";
                password = "{{HOMEPAGE_VAR_TRANSMISSION_PASSWORD}}";
                rpcUrl = "/transmission/";
              };
            };
          }
          {
            OpenBooks = {
              icon = "bookstack.png";
              description = "Search and Download eBooks.";
              href = "https://openbooks.${vars.traefik.domain}";
            };
          }
        ];
      }
      {
        Useful = [
          {
            Authentik = {
              icon = "authentik.png";
              href = "https://authentik.${vars.traefik.domain}";
              description = "Take control of your identity needs with a secure, flexible solution.";
              widget = {
                type = "authentik";
                url = "http://127.0.0.1:${toString vars.authentik.port}";
                key = "{{HOMEPAGE_VAR_AUTHENTIK_TOKEN}}";
                version = "2";
              };
            };
          }
          {
            Matrix = {
              icon = "matrix.png";
              href = "https://matrix.${vars.traefik.domain}";
              description = "An open network for secure, decentralised communication";
            };
          }
          {
            Vaultwarden = {
              icon = "bitwarden.png";
              href = "https://vaultwarden.${vars.traefik.domain}";
              description = "Unofficial Bitwarden compatible server written in Rust, formerly known as bitwarden_rs";
            };
          }
          {
            Nextcloud = {
              icon = "nextcloud.png";
              href = "https://nextcloud.${vars.traefik.domain}";
              description = "A safe home for all you data";
            };
          }
          {
            Blog = {
              href = "https://blog.${vars.traefik.domain}";
              description = "My personal blog mainly about my server !";
            };
          }
        ];
      }
      {
        Widgets = [
          {
            Calendar = {
              widget = {
                type = "calendar";
                firstDayInWeek = "monday";
                view = "monthly";
                maxEvents = 5;
                showTime = true;
                timezone = "Europe/Paris";
                integrations = [
                  {
                    type = "sonarr";
                    service_group = "Request Utilities";
                    service_name = "Sonarr";
                    color = "cyan";
                  }
                  {
                    type = "radarr";
                    service_group = "Request Utilities";
                    service_name = "Radarr";
                    color = "amber";
                  }
                ];
              };
            };
          }
        ];
      }
      {
        "Admin Tools" = [
          {
            Tailscale = {
              icon = "tailscale.png";
              description = "Drop you VPN, not your standards";
              href = "https://tailscale.com";
            };
          }
          {
            Grafana = {
              icon = "grafana.png";
              description = "The open and composable observability platform";
              href = "https://grafana.${vars.traefik.domain}";
            };
          }
          {
            Traefik = {
              icon = "traefik.png";
              href = "https://traefik.${vars.traefik.domain}";
              description = "The Cloud Native Application Proxy";
            };
          }
          {
            Maintainerr = {
              icon = "maintainerr.png";
              description = "The Perfect Media Janitor";
              href = "https://maintainerr.${vars.traefik.domain}";
            };
          }
        ];
      }
    ];
    customCSS = ''
      * {
      	font-weight: bold;
      	font-family: "CaskaydiaCove Nerd Font",Manrope,Manrope-Fallback,Arial,sans-serif;
      }
      .service-card {
      	background-color: rgba(51, 51, 51, 0.4);
      }
      .service-block {
      	background: transparent;
      }
      		'';
    settings = {
      layout = {
        Streaming = {
          style = "row";
          columns = 4;
        };
        "Request Utilities" = {
          style = "row";
          columns = 4;
        };
        Useful = {
          style = "row";
          columns = 4;
        };
        Widgets = {
          style = "row";
          columns = 4;
        };
        "Admin Tools" = {
          style = "row";
          columns = 4;
        };
      };
      theme = "dark";
      background = {
        image = "https://github.com/HyDE-Project/hyde-themes/blob/Catppuccin-Mocha/Configs/.config/hyde/themes/Catppuccin%20Mocha/wallpapers/cat_leaves.png?raw=true";
        blur = "md";
      };
      headerStyle = "clean";
      quickLaunch = {
        searchDescriptions = "true";
        hideInternetSearch = "true";
        showSearchSuggestions = "true";
        hideVisitURL = "true";
        provider = "duckduckgo";
      };
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    services.homepage.loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${toString config.services.homepage-dashboard.listenPort}";
      }
    ];
    routers.homepage = {
      rule = "Host(`${vars.traefik.domain}`)";
      tls = true;
      service = "homepage";
      entrypoints = "websecure";
    };
  };
}
