let
  virtiofsShare = { tag, source, mountPoint }: {
    inherit tag source mountPoint;
    proto = "virtiofs";
  };
in
{
  inherit virtiofsShare;

  mk = {
    inputs,
    address, # Guest address with prefix, e.g. "192.168.83.7/24".
    aiCliPackages,
    aiVmPackages,
    gateway,
    mac,
    mem, # Guest RAM in MiB.
    name,
    tap,
    extraShares ? [], # virtiofs entries appended after the read-only nix store share.
  }: {
  autostart = false;
  specialArgs = { inherit inputs; };

  config = { lib, pkgs, inputs, ... }: let
    inherit (lib) mkDefault;
    homeState = "/var/lib/home-state";
    bindMount = source: {
      device = source;
      fsType = "none";
      options = [ "bind" ];
    };
  in {
    imports = [
      ../dev/nixos.nix
      ../terminal/nixos.nix
      ../system-generic/nixos.nix
      inputs.home-manager.nixosModules.home-manager
    ];

    # This pulls in nixos-containers which depends on Perl.
    boot.enableContainers = mkDefault false;

    documentation = {
      enable = mkDefault false;
      doc.enable = mkDefault false;
      info.enable = mkDefault false;
      man.enable = mkDefault false;
      nixos.enable = mkDefault false;
    };

    environment = {
      defaultPackages = mkDefault [ ];  # IE Perl is a default package.
      stub-ld.enable = mkDefault false;
      systemPackages = aiCliPackages ++ aiVmPackages;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.maarten = {
        imports = [
          ../ai/home-manager.nix
          ../dev/home-manager.nix
          ../terminal/home-manager.nix
        ];
        home.stateVersion = "26.05";
      };
    };

    microvm = {
      hypervisor = "cloud-hypervisor";
      interfaces = [{
        type = "tap";
        id = tap;
        inherit mac;
      }];
      inherit mem;
      # It is highly recommended to share the host's nix-store with the VMs to prevent building huge images.
      shares = [
        (virtiofsShare {
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        })
      ] ++ extraShares;
      socket = "/tmp/microvm-${name}.sock";
      vcpu = 8;
      volumes = [
        {
          mountPoint = "/var";
          image = "var.img";
          size = 8192; # MB
        }
        {
          mountPoint = homeState;
          image = "home-state.img";
          size = 4096; # MB — pi, opencode config/cache
        }
      ];
      # No writableStoreOverlay: overlay-on-virtiofs is unsupported as an
      # upper layer and is not needed without in-guest nix builds.
    };

    networking = {
      # Disable firewall for faster boot and less hassle;
      # we are behind a layer of NAT anyway.
      firewall.enable = false;
      hostName = name;
      nameservers = [
        "8.8.8.8"
        "1.1.1.1"
      ];
      tempAddresses = "disabled";
      useDHCP = false;
      useNetworkd = true;
    };

    programs = {
      command-not-found.enable = mkDefault false;
      # The lessopen package pulls in Perl.
      less.lessopen = mkDefault null;
    };

    services = {
      # dbus-broker needs inotify, which virtiofs still does not provide.
      dbus.implementation = "dbus";
      openssh = {
        enable = true;
        # Persist keys on the /var volume so boot doesn't hang regenerating them on tmpfs.
        hostKeys = [
          {
            path = "/var/lib/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
        settings = {
          AllowUsers = [ "maarten" ];
          PermitRootLogin = "no";
        };
      };
      resolved.enable = true;
      udisks2.enable = mkDefault false;
    };

    system.stateVersion = "26.05";

    fileSystems = {
      "/home/maarten/.pi" = bindMount "${homeState}/.pi";
      "/home/maarten/.config/opencode" = bindMount "${homeState}/opencode";
      "/home/maarten/.cache/opencode" = bindMount "${homeState}/opencode-cache";
    };

    systemd = {
      # Home Manager activation runs as the user and needs nix-daemon
      # (single-user nix cannot lock /nix/var). Store stays read-only via
      # virtiofs — builds still will not work, but realise/gc-roots will.
      # microvm defaults these off without writableStoreOverlay.
      services.nix-daemon.enable = lib.mkForce true;
      sockets.nix-daemon.enable = lib.mkForce true;
      network.networks."10-lan" = {
        matchConfig.Name = "en* eth*";
        address = [ address ];
        gateway = [ gateway ];
      };
      oomd.enable = true;
      tmpfiles.rules = [
        "d /var/lib/ssh 0755 root root -"
        "d ${homeState}/.pi 0700 maarten maarten -"
        "d ${homeState}/opencode 0750 maarten maarten -"
        "d ${homeState}/opencode-cache 0755 maarten maarten -"
        "d /home/maarten/.config 0755 maarten maarten -"
        "d /home/maarten/.cache 0755 maarten maarten -"
        "d /home/maarten/.pi 0700 maarten maarten -"
        "d /home/maarten/.config/opencode 0750 maarten maarten -"
        "d /home/maarten/.cache/opencode 0755 maarten maarten -"
      ];
      # Fix for microvm shutdown hang (issue #170):
      # Without this, systemd tries to unmount /nix/store during shutdown, but umount lives in /nix/store, causing a deadlock.
      mounts = [{
        what = "store";
        where = "/nix/store";
        overrideStrategy = "asDropin";
        unitConfig.DefaultDependencies = false;
      }];
      settings.Manager = {
        # fast shutdowns/reboots! https://mas.to/@zekjur/113109742103219075
        DefaultTimeoutStopSec = "5s";
      };
    };

    users = {
      groups.maarten.gid = 1000;
      users.maarten = {
        group = "maarten";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcUcPxEtlNoXBg6jvIeqr/3hc9GgQplrQtyd215bi5cDIeo7qx6INlOhrZ/M88TN1/HllRi/ygWZWwUxL2aruzB2jLmbN2cGpAeQFH1u8daZT0GtZv4Iu7426k5UXEjd6QxtJEXMUeg8czN9fB7aqntjfl7uVmVl/cozqbM7bF00F8MCKGERpWjglDsuqC7qcK8kMVmcgoe8cGpffj+2zUL/HiMZptJN2GXpN7kDIKUNrUezFLG1osH2lAeox6W6tEG18w+UtgQ4qSEs4ob9MdQBOMgv/8RuAft9ma4yxrEKoy8+ogKacuy6gU/U5Y7ulAS6TWqto+8VKQyRm/vfc5 maarten@lagash"
        ];
      };
    };

    xdg = {
      autostart.enable = mkDefault false;
      icons.enable = mkDefault false;
      mime.enable = mkDefault false;
      sounds.enable = mkDefault false;
    };
  };
  };
}
