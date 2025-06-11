{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        imageSize = "32G"; # For test VMs
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              end = "-4G";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
          };
        };
      };
    };
    zpool = {
      tank = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
        };
        mountpoint = null;
        postCreateHook = "zfs snapshot -r tank@blank && zfs hold -r blank tank@blank";

        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          persist = {
            type = "zfs_fs";
            mountpoint = "/persist";
          };
        };
      };
    };
  };
}
