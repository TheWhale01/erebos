{
  description = "whale's NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blog-builder = {
      url = "github:TheWhale01/blog-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cleanerr = {
      url = "github:TheWhale01/cleanerr?ref=test";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    authentik = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    modules = {
      url = "github:TheWhale01/nixos-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
  {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    agenix,
    disko,
    blog-builder,
    cleanerr,
    authentik,
    modules,
    terranix,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      system = system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
      	"immich-2.7.5"
      ];
    };
    erebosConfig = { env }: lib.nixosSystem {
      inherit pkgs;
      specialArgs = {
        inherit inputs env;
        vars = import ./sys/vars.nix { inherit env; };
        pkgs-unstable = import nixpkgs-unstable {
          system = "${system}";
          config.allowUnfree = true;
        };
      };
      modules = [
        ./sys/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hades = import ./sys/home.nix;
          home-manager.backupFileExtension = "bkp";
          home-manager.extraSpecialArgs = { inherit inputs env; };
        }
        agenix.nixosModules.default
        disko.nixosModules.disko
        blog-builder.nixosModules.default
        cleanerr.nixosModules.default
        authentik.nixosModules.default
        modules.nixosModules.system
      ];
    };
    terranixState = { env }: terranix.lib.terranixConfiguration {
      inherit system;
      modules = [ ./sys/terraform ];
      extraArgs = {
        erebos = erebosConfig { env = env; };
        vars = import ./sys/vars.nix { inherit env; };
      };
    };
  in
  {
    nixosConfigurations.erebos = erebosConfig { env = "prod"; };
    nixosConfigurations.erebos-stage = erebosConfig { env = "stage"; };
    apps.${pkgs.stdenv.hostPlatform.system} = {
      apply = {
        type = "app";
        program = toString (pkgs.writers.writeBash "apply" ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          cp ${terranixState { env = "prod"; }} config.tf.json
          ${pkgs.opentofu}/bin/tofu init
          ${pkgs.opentofu}/bin/tofu apply
        '');
      };
      apply-stage = {
        type = "app";
        program = toString (pkgs.writers.writeBash "apply" ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          cp ${terranixState { env = "stage"; }} config.tf.json
          ${pkgs.opentofu}/bin/tofu init
          ${pkgs.opentofu}/bin/tofu apply
        '');
      };
    };
  };
}
