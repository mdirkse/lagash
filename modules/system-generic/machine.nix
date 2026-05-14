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
    kernel = {
      sysctl."fs.inotify.max_user_watches" = 524288;
      sysctl."net.ipv4.ip_forward" = 0;
    };

    tmp.useTmpfs = true;
  };

  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;


  networking.timeServers = options.networking.timeServers.default ++ [
    "0.nl.pool.ntp.org"
    "1.nl.pool.ntp.org"
  ];

  programs.command-not-found.enable = false;

  time.timeZone = "Europe/Amsterdam";
}
