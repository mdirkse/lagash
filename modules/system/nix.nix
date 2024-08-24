{ inputs, lib, config, options, pkgs, ... }: {
  nix.nixPath = [ "/etc/nix/path" ];

  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.settings = {
    allowed-users = [ "@wheel" ];
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
  };

  nixpkgs = { config = { allowUnfree = true; }; };

  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };
}
