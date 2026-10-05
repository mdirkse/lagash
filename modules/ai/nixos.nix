{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  aiCliPackages = with pkgs; [
    beads
    cloud-hypervisor
    claude-code
    cursor-cli
    opencode
    openspec
    pi-coding-agent
  ];
  aiVmPackages = with pkgs; [
    buildkite-cli
    netlify-cli
    nodejs
    pnpm
    python3
    sqlite
  ];
  bridgeName = "aibr";
  bridgeIp = "192.168.83.1";
  tapNamePrefix = "aivm";
  home = config.users.users.maarten.home;
  inherit (import ./vm-template.nix) mk virtiofsShare;
in
{

  environment.systemPackages = aiCliPackages;

  ## Network configuration for AI VMs (bridge + NAT). Requires systemd-networkd for the
  ## .netdev / .network units; NetworkManager is told not to own the bridge (physical NICs
  ## stay on NM). After `nixos-rebuild switch`, see the bridge with `ip -br a` /
  ## `networkctl status ${bridgeName}`.
  systemd.network = {
    # WiFi/Ethernet stay on NetworkManager; networkd only manages the AI VM bridge.
    # wait-online has nothing to wait for and times out in that setup.
    wait-online.enable = false;

    netdevs."20-${bridgeName}".netdevConfig = {
      Kind = "bridge";
      Name = bridgeName;
    };

    networks."20-${bridgeName}" = {
      matchConfig.Name = bridgeName;
      addresses = [ { Address = "${bridgeIp}/24"; } ];
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };

    networks."21-${tapNamePrefix}-tap" = {
      matchConfig.Name = "${tapNamePrefix}*";
      networkConfig.Bridge = bridgeName;
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ bridgeName ];
    # Default/null: do not match a fixed uplink by name. Masquerade applies on whatever interface actually carries forwarded traffic (typically the
    # machine’s default-route / Ethernet WAN), so this works across eno1, enp*s0, etc.
    externalInterface = null;
  };

  networking.networkmanager.unmanaged = [ "interface-name:${bridgeName}" ];
  networking.firewall.trustedInterfaces = [ bridgeName ];

  microvm.vms = {
    personal = mk {
      inherit inputs aiCliPackages aiVmPackages;
      name = "personalvm";
      address = "192.168.83.8/24";
      mac = "02:00:00:00:00:07";
      mem = 4096;
      tap = "${tapNamePrefix}0";
      gateway = bridgeIp;
      extraShares = [
        (virtiofsShare {
          tag = "source";
          source = "${home}/Source";
          mountPoint = "${home}/Source";
        })
      ];
    };
    work = mk {
      inherit inputs aiCliPackages aiVmPackages;
      name = "jumbovm";
      address = "192.168.83.7/24";
      mac = "02:00:00:00:00:06";
      mem = 4096;
      tap = "${tapNamePrefix}0";
      gateway = bridgeIp;
      extraShares = [
        (virtiofsShare {
          tag = "work-jumbo";
          source = "${home}/Work/jumbo";
          mountPoint = "${home}/Work/jumbo";
        })
      ];
    };
  };
}
