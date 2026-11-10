{ config, ... }:

{
  services.loki = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3100;
      };
      auth_enabled = false;
      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "${config.services.loki.dataDir}";
        storage = {
          filesystem =  {
            chunks_directory = "${config.services.loki.configuration.common.path_prefix}/chunks";
            rules_directory = "${config.services.loki.configuration.common.path_prefix}/rules";
          };
        };
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };
      schema_config.configs = [{
        from = "2024-01-01";
        store = "tsdb";
        object_store = "filesystem";
        schema = "v13";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }];
      compactor = {
        retention_enabled = true;
        delete_request_store = "filesystem";
        working_directory = "${config.services.loki.dataDir}/compactor";
        compaction_interval = "10m";
      };
      limits_config = {
        retention_period = "720h"; # 1 month
      };
    };
  };
}
