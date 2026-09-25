{ pkgs, lib, ... }:

{
  imports = [
    ./openbooks.nix
    ./transmission.nix
    ./gluetun.nix
    ./nextcloud.nix
    ./maintainerr.nix
    ./actualbudget.nix
    ./lidarr.nix
    ./authentik.nix
  ];

  virtualisation = {
    oci-containers.backend = "podman";
    containers = {
      enable = true;
      storage.settings.storage = {
        driver = "overlay";
        runroot = "/run/containers/storage";
        graphroot = "/var/lib/containers/storage";
        rootless_storage_path = "/tmp/containers-$USER";
        options.overlay.mountopt = "nodev,metacopy=on";
      };
    };
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        flags = [ "--all" "--force" "--volumes" ];
      };
      defaultNetwork.settings = {
        dns_enabled = true;
        ipv6_enabled = true;
      };
    };
  };
  environment.extraInit = ''
    if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
      export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
    fi
  '';
  systemd.services.update-containers = {
    startAt = "daily";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe (pkgs.writeShellScriptBin "update-containers" ''
        images=$(${pkgs.podman}/bin/podman ps -a --format="{{.Image}}" | sort -u)
       	for image in $images; do
          ${pkgs.podman}/bin/podman pull "$image"
       	done
        systemctl restart 'podman-*.service'
      '');
    };
  };
}
