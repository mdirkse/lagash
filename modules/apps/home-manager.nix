{ inputs, lib, config, pkgs, ... }: {
  home.file."bin/winvm".source = ./resources/bin/winvm;
  home.file."bin/jumbovm".source = ./resources/bin/jumbovm;

  # Chrome apps
  home.file."bin/outlook".source = ./resources/bin/outlook;
  home.file."bin/teams".source = ./resources/bin/teams;
}
