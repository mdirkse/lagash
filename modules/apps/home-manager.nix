{ inputs, lib, config, pkgs, ... }: {
  home.file."bin/chrome-wayland".source = ./resources/bin/chrome-wayland;
  home.file."bin/slack-wayland".source = ./resources/bin/slack-wayland;
  home.file."bin/spotify-wayland".source = ./resources/bin/spotify-wayland;
  home.file."bin/winvm".source = ./resources/bin/winvm;

  # Chrome apps
  home.file."bin/chatgpt".source = ./resources/bin/chatgpt;
  home.file."bin/outlook".source = ./resources/bin/outlook;
  home.file."bin/teams".source = ./resources/bin/teams;
}
