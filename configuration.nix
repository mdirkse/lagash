{ inputs, lib, config, options, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    "${
      builtins.fetchTarball {
        url =
          "https://github.com/nix-community/disko/archive/refs/tags/v1.4.1.tar.gz";
        sha256 = "1hm5fxpbbmzgl3qfl6gfc7ikas4piaixnav27qi719l73fnqbr8x";
      }
    }/module.nix"
    ./hardware/disko-config.nix
    ./modules/apps/nixos.nix
    ./modules/dev/nixos.nix
    ./modules/terminal/nixos.nix
    ./modules/wm/nixos.nix
  ];

  nixpkgs = { config = { allowUnfree = true; }; };

  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; }))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  networking.hostId = "a4ae363c";
  networking.hostName = "lagash";
  networking.networkmanager.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = [ "zfs" ];

  boot.kernelParams = [ "mem_sleep_default=deep" ];

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 0;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  networking.timeServers = options.networking.timeServers.default
    ++ [ "0.nl.pool.ntp.org" "1.nl.pool.ntp.org" ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  time.timeZone = "Europe/Amsterdam";

  users.users = {
    maarten = {
      extraGroups = [ "docker" "vboxusers" "video" "wheel" ];
      initialPassword = "paratodostodo";
      isNormalUser = true;
      shell = pkgs.fish;
    };
  };

  security.sudo.extraRules = [{
    users = [ "maarten" ];
    commands = [{
      command = "ALL";
      options = [ "SETENV" "NOPASSWD" ];
    }];
  }];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion  # You can import other home-manager modules here
  system.stateVersion = "23.11";

  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = lib.mkDefault ''
    {
        "dns": ["8.8.8.8", "4.4.4.4"],
        "max-concurrent-downloads": 5,
        "selinux-enabled": false
      }'';
  virtualisation.docker.storageDriver = "zfs";
}
