{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./modules/apps/home-manager.nix
    ./modules/ai/home-manager.nix
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

  # Used by `nix` / `nixpkgs` flake commands (e.g. `nix profile install nixpkgs#…`).
  # NixOS `nixpkgs.config` does not apply to those evaluations.
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    }
  '';

  home = {
    username = "maarten";
    homeDirectory = "/home/maarten";
    sessionPath = [ "$HOME/bin" ];
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    signing.format = "openpgp";
  };

  gtk.gtk4.theme = config.gtk.theme;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "26.05";
}
