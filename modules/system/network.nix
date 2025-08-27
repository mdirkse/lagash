{ inputs, lib, config, options, pkgs, ... }: {
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  networking.hostId = "a4ae363c";
  networking.hostName = "lagash";

  networking.networkmanager.enable = true;

  services.tailscale.enable = true;
  systemd.services."tailscaled".wantedBy = lib.mkForce [ ];

  networking.networkmanager.dispatcherScripts = [{
    source = pkgs.writeShellScript "wifi-ethernet-switch" ''
      NM_CLI="${pkgs.networkmanager}/bin/nmcli"
      IFACE="$1"
      STATUS="$2"

      if [ "$IFACE" = "enp58s0u1u2u1c2" ]; then
        if [ "$STATUS" = "up" ]; then
            $NM_CLI radio wifi off
        elif [ "$STATUS" = "down" ]; then
            $NM_CLI radio wifi on
        fi
      fi
    '';
  }];
}
