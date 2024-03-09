{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    "${builtins.fetchTarball {
        url = "https://github.com/nix-community/disko/archive/refs/tags/v1.4.1.tar.gz";
        sha256 = "1hm5fxpbbmzgl3qfl6gfc7ikas4piaixnav27qi719l73fnqbr8x";
    }}/module.nix"
    ./disko-config.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = ["zfs"];

  networking.hostId = "a4ae363c";
  networking.hostName = "lagash-nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; [
    wget
  ];

  system.stateVersion = "23.11";
}
