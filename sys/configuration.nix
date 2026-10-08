{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./services
    ./packages.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelModules = [ "r8712u" ];
  boot.kernelParams = [ "ipv6.disable=1" ];

  networking.hostName = "strategos";
  networking.enableIPv6 = false;
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  time.timeZone = "Europe/Paris";

  hardware.enableRedistributableFirmware = true;

  swapDevices = [
    {
      device = "/var/lib/swap/swapfile";
      size = 4096;
    }
  ];

  nix.settings = {
    experimental-features = [
        "nix-command"
        "flakes"
      ];
    trusted-users = [ "root" "athena" ];
  };

  users.users.athena = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMircTS6VhZz/0Hc1pwYYl/Eov7MXNKd9rJLYjGMRfZz poseidon@pontos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9FADovUTXSn2694wMAViLnDJRn3TypRSzGHy3MNTo9 hades@erebos"
    ];
  };

  programs.zsh.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
