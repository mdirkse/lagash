{ inputs, lib, config, options, pkgs, ... }: {
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 0;
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.tmp.useTmpfs = true;

  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  networking.timeServers = options.networking.timeServers.default
    ++ [ "0.nl.pool.ntp.org" "1.nl.pool.ntp.org" ];

  programs.command-not-found.enable = false;

  security.sudo.extraRules = [{
    users = [ "maarten" ];
    commands = [{
      command = "ALL";
      options = [ "SETENV" "NOPASSWD" ];
    }];
  }];
  security.rtkit.enable = true;

  services.avahi.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  system.switch = {
    enable = false;
    enableNg = true;
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

  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = lib.mkDefault ''
    {
        "dns": ["8.8.8.8", "4.4.4.4"],
        "max-concurrent-downloads": 5,
        "selinux-enabled": false
      }'';
  virtualisation.docker.storageDriver = "zfs";
}
