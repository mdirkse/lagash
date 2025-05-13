{ inputs, lib, config, pkgs, ... }: {
  xdg.configFile."fish/conf.d/autostart-niri.fish".source = ./resources/autostart-niri.fish;
  xdg.configFile."niri/config.kdl".source = ./resources/config.kdl;
}
