{ inputs, lib, config, pkgs, ... }: {
  # Fish config
  home.file."bin/uptime-procps".source = "${pkgs.procps}/bin/uptime";
  xdg.configFile."fish/functions/aws-creds.fish".source = ./resources/fish/functions/aws-creds.fish;
  xdg.configFile."fish/functions/fish_greeting.fish".source = ./resources/fish/functions/fish_greeting.fish;
  xdg.configFile."fish/functions/fix-bluetooth.fish".source = ./resources/fish/functions/fix-bluetooth.fish;
  xdg.configFile."fish/functions/g-discard-merged-branch.fish".source = ./resources/fish/functions/g-discard-merged-branch.fish;
  xdg.configFile."fish/functions/g-update-current-commit.fish".source = ./resources/fish/functions/g-update-current-commit.fish;
  xdg.configFile."fish/functions/gspp.fish".source = ./resources/fish/functions/gspp.fish;
  xdg.configFile."fish/functions/update-system.fish".source = ./resources/fish/functions/update-system.fish;

  xdg.configFile."kitty/kitty.conf".source = ./resources/kitty.conf;

}
