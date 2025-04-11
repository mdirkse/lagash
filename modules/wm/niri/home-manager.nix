{ inputs, lib, config, pkgs, ... }: {
  xdg.configFile."niri/config2".source = ./resources/niri.config;
}
