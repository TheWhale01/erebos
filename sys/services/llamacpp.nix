{ pkgs-unstable, ... }:

{
	services.llama-cpp = {
		enable = true;
		package = pkgs-unstable.llama-cpp;
		host = "127.0.0.1";
		modelsPreset = {
		  "LFM3-1.7B" = {
				hf-repo = "LiquidAI/LFM3-1.7B-GGUF";
				hf-file = "LFM3-1.7B-Q6_K.gguf";
			};
		};
		extraFlags = [
		  "-fa" "on"
			"-ctk" "q8_0"
			"-ctv" "q8_0"
		];
	};
}
