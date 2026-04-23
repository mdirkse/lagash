{ inputs, lib, config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    beads
    claude-code
    cursor-cli
    opencode
  ];

  ## Network configuration for AI VMs (bridge + NAT). Requires systemd-networkd for the
  ## .netdev / .network units; NetworkManager is told not to own the bridge (physical NICs
  ## stay on NM). After `nixos-rebuild switch`, see `aibr` with `ip -br a` / `networkctl status aibr`.
  systemd.network = {
    # Bridge has no “online” state until taps exist; do not block boot on it.
    wait-online.ignoredInterfaces = [ "aibr" ];

    netdevs."20-aibr".netdevConfig = {
      Kind = "bridge";
      Name = "aibr";
    };

    networks."20-aibr" = {
      matchConfig.Name = "aibr";
      addresses = [ { Address = "192.168.83.1/24"; } ];
      networkConfig = { ConfigureWithoutCarrier = true; };
    };

    networks."21-aivm-tap" = {
      matchConfig.Name = "aivm*";
      networkConfig.Bridge = "aibr";
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "aibr" ];
    # Default/null: do not match a fixed uplink by name. Masquerade applies on whatever interface actually carries forwarded traffic (typically the
    # machine’s default-route / Ethernet WAN), so this works across eno1, enp*s0, etc.
    externalInterface = null;
  };

  networking.networkmanager.unmanaged = [ "interface-name:aibr" ];
  networking.firewall.trustedInterfaces = [ "aibr" ];
}
