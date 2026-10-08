{
	description = "whale's NixOS";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		modules = {
			url = "path:/home/hades/nixos-modules";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, home-manager, modules, ... }@inputs:
	let
		lib = nixpkgs.lib;
		pkgsFor = system: import nixpkgs {
			inherit system;
			config.allowUnfree = true;
			config.allowBroken = true;
		};
	in {
		nixosConfigurations = {
			strategos = lib.nixosSystem {
				system = "aarch64-linux";
				pkgs = pkgsFor "aarch64-linux";
				modules = [
					./sys/configuration.nix
					home-manager.nixosModules.home-manager {
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.users.athena = import ./sys/home.nix;
						home-manager.backupFileExtension = "bkp";
						home-manager.extraSpecialArgs = { inherit inputs; };
					}
					modules.nixosModules.system
				];
			};
		};
	};
}
