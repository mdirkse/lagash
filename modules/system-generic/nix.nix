{
  inputs,
  lib,
  config,
  options,
  pkgs,
  ...
}:
{
  nix.nixPath = [ "/etc/nix/path" ];

  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.settings = {
    allowed-users = [ "@wheel" ];
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  # microvm guests get an external `pkgs` (host instance). Setting
  # nixpkgs.config there trips the nixpkgs assertion; allowUnfree already
  # applies via the shared host pkgs.
  nixpkgs.config = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
    allowUnfree = true;
  };

  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";
}
