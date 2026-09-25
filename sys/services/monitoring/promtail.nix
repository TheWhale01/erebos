{ config, ... }:

{
	services.alloy = {
		enable = true;
	};
	# services.promtail = {
  	#   enable = true;
  	#   configuration = {
  	#     server = {
  	#       http_listen_port = 9080;
  	#       grpc_listen_port = 9081;
  	#     };
  	#     positions.filename = "/tmp/positions.yaml";
  	#     clients = [{
  	#       url = "http://${config.services.loki.configuration.common.instance_addr}:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
  	#     }];
  	#     scrape_configs = [
  	#       {
  	#         job_name = "journal";
  	#         journal = {
  	#           max_age = "12h";
  	#           labels = {
  	#             job = "systemd-journal";
  	#             host = "erebos";
  	#           };
  	#         };
  	#         relabel_configs = [
  	#           {
  	#             source_labels = [ "__journal__systemd_unit" ];
  	#             target_label = "unit";
  	#           }
  	#         ];
  	#         pipeline_stages = [{
  	#           match = {
  	#             selector = "{unit=\"traefik.service\"}";
  	#             stages = [
  	#               { json.expressions.ip = "ClientHost"; }
  	#               {
  	#                 geoip = {
  	#                   source = "ip";
  	#                   db = "/var/lib/geoip/GeoLite2-City.mmdb";
  	#                   db_type = "city";
  	#                 };
  	#               }
  	#             ];
  	#           };
  	#         }];
  	#       }
  	#     ];
  	#   };
  	# };
	# users.users.promtail.extraGroups = [ "systemd-journal" ];
}
