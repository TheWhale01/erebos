{ inputs, ... }:

{
  imports = [
    inputs.modules.nixosModules.homeManager
    ./direnv.nix
  ];

  programs.home-manager.enable = true;
}
