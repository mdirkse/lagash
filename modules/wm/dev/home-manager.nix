{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."Code/User/keybindings.json".source = ./resources/code/keybindings.json;
  xdg.configFile."Code/User/settings.json".source = ./resources/code/settings.json;
}
