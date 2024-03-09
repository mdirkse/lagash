{
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "64M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks_zfs = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = [ ];
                settings = { allowDiscards = true; };
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        options = { ashift = "12"; };
        rootFsOptions = {
          atime = "off";
          "com.sun:auto-snapshot" = "false";
          compression = "lz4";
          xattr = "sa";
        };
        mountpoint = "/";
        postCreateHook = "zfs snapshot zroot@blank";

        datasets = {
          home_fs = {
            type = "zfs_fs";
            mountpoint = "/home";
            options."com.sun:auto-snapshot" = "true";
          };
          root_fs = {
            type = "zfs_fs";
            mountpoint = "/root";
          };
          log_fs = {
            type = "zfs_fs";
            mountpoint = "/var/log";
          };
        };
      };
    };
  };
}
