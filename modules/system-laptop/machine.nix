{
  inputs,
  lib,
  config,
  options,
  pkgs,
  ...
}:
{
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    kernelParams = [ "mem_sleep_default=deep" ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
