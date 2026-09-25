{ vars,  ... }:

# !!! FOR NOW THIS PROVIDER IS NOT USEABLE !!!
# !!! DO NOT USE !!!
{
  terraform.required_providers.jellyfin ={
    source = "registry.terraform.io/ThePhaseless/jellyfin";
  };

  provider.jellyfin = {
    endpoint = "http://127.0.0.1:${toString vars.jellyfin.port}";
    api_key = "\${trimspace(file(\"/run/agenix/jellyfin-terraform\"))}";
  };

  resource.jellyfin_library = {
    movies = {
      name = "Movies";
      collection_type = "movies";
      paths = ["/data/Movies"];
    };
    tvshows = {
      name = "TV Shows";
      collection_type = "tvshows";
      paths = ["/data/Series"];
    };
    animes = {
      name = "Animes";
      collection_type = "tvshows";
      paths = ["/data/Animes"];
    };
    books = {
      name = "Books";
      collection_type = "books";
      paths = ["/data/Books"];
    };
  };

  resource.jellyfin_plugin_repository = {
    jellyfin_stable = {
      name = "Jellyfin Stable";
      url = "https://repo.jellyfin.org/files/plugin/manifest.json";
      enabled = true;
    };
    intro_skipper = {
      name = "intro-skipper";
      url = "https://intro-skipper.org/manifest.json";
      enabled = true;
    };
    moonfin = {
      name = "Moonfin";
      url = "https://raw.githubusercontent.com/Moonfin-Client/Plugin/refs/heads/master/manifest.json";
      enabled = true;
    };
    file_transformation = {
      name = "File Transformation";
      url = "https://www.iamparadox.dev/jellyfin/plugins/manifest.json";
      enabled = true;
    };
  };
}
