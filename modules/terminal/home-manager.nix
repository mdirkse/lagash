{ inputs, lib, config, pkgs, ... }: {
  # Fish config
  xdg.configFile."fish/functions/aws-creds.fish".source = ./resources/fish/functions/aws-creds.fish;
  xdg.configFile."fish/functions/fish_greeting.fish".source = ./resources/fish/functions/fish_greeting.fish;
  xdg.configFile."fish/functions/git-update-current-commit.fish".source = ./resources/fish/functions/git-update-current-commit.fish;
  xdg.configFile."fish/functions/gitspp.fish".source = ./resources/fish/functions/gitspp.fish;
  xdg.configFile."fish/functions/update-system.fish".source = ./resources/fish/functions/update-system.fish;

  xdg.configFile."kitty/kitty.conf".source = ./resources/kitty.conf;

}
