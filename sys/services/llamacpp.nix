{ pkgs-unstable, ... }:

{
	services.llama-cpp = {
		enable = true;
		package = pkgs-unstable.llama-cpp-vulkan;
		host = "0.0.0.0";
		modelsPreset = {
		  "LFM3-1.7B" = {
				hf-repo = "LiquidAI/LFM3-1.7B-GGUF";
				hf-file = "LFM3-1.7B-Q4_K_M.gguf";
			};
		};
		extraFlags = [
		      "-ngl" "99"
		      "-fa" "on"
		      "-b" "2048"
		      "-ub" "512"
		      "--cache-reuse" "256"
		];
	};
	systemd.services.llama-cpp = {
		environment = {
			GGML_VK_VISIBLE_DEVICES = "0";
		};
		serviceConfig = {
			SupplementaryGroups = [ "render" "video" ];
		};
	};
}
