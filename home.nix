{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./modules/apps/home-manager.nix
    ./modules/dev/home-manager.nix
    ./modules/terminal/home-manager.nix
    ./modules/wm/home-manager.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "maarten";
    homeDirectory = "/home/maarten";
    sessionPath = [ "$HOME/bin" ];
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.11";
}
