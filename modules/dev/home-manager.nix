{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  home.file.".cargo/cargo.config".source = ./resources/cargo.config;
  home.file.".gitconfig".source = ./resources/.gitconfig;
  home.file.".gradle/gradle.properties".source = ./resources/gradle.properties;

  xdg.configFile."Code/User/keybindings.json".source = ./resources/code/keybindings.json;
  xdg.configFile."Code/User/settings.json".source = ./resources/code/settings.json;

  # Completions
  xdg.configFile."fish/completions/kubectx.fish".source = ./resources/code/keybindings.json;
}
