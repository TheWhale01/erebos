{ lib, ... }:
{
  disko.devices = {
    disk = {
      nixos = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/";
              };
            };
          };
        };
      };
      data = {
        type = "lvm";
        device = "/dev/mapper/whale--nas-data";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/data";
          mountOptions = [
            "defaults"
            "noatime"
          ];
        };
      };
    };
  };
  boot.initrd.postDeviceCommands = lib.mkAfter ''
		"lvm vgchange -ay"
 	'';
}
