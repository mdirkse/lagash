{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  home.file.".cargo/config.toml".source = ./resources/config.toml;
  home.file.".gitconfig".source = ./resources/.gitconfig;
  home.file.".gradle/gradle.properties".source = ./resources/gradle.properties;
}
