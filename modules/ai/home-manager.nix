{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  home.file.".claude/settings.json" = {
    source = ./resources/claude/settings.json;
    force = true;
  };

  home.file.".cursor/cli-config.json" = {
    source = ./resources/cursor/cli-config.json;
    force = true;
  };

  xdg.configFile."opencode/opencode.json" = {
    source = ./resources/opencode/opencode.json;
    force = true;
  };
}
