{ inputs, lib, config, pkgs, ... }: {
  xdg.configFile."fish/functions/screenshot.fish".source = ./resources/screenshot.fish;
  xdg.configFile."sway/config".source = ./resources/sway.config;
}
