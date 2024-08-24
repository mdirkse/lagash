{ inputs, lib, config, options, pkgs, ... }: {
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  networking.hostId = "a4ae363c";
  networking.hostName = "lagash";

  networking.networkmanager.enable = true;

  services.tailscale.enable = true;
}
