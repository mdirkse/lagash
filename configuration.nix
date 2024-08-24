{ inputs, lib, config, options, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    "${
      builtins.fetchTarball {
        url =
          "https://github.com/nix-community/disko/archive/refs/tags/v1.4.1.tar.gz";
        sha256 = "1hm5fxpbbmzgl3qfl6gfc7ikas4piaixnav27qi719l73fnqbr8x";
      }
    }/module.nix"
    ./hardware/disko-config.nix
    ./modules/apps/nixos.nix
    ./modules/dev/nixos.nix
    ./modules/system/nixos.nix
    ./modules/terminal/nixos.nix
    ./modules/wm/nixos.nix
  ];

  system.stateVersion = "23.11";
}
