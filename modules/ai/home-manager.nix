{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.ssh.settings = {
    personalvm = {
      User = "maarten";
      HostName = "192.168.83.8";
    };
    jumbovm = {
      User = "maarten";
      HostName = "192.168.83.7";
    };
  };

  home.file.".claude/settings.json" = {
    source = ./resources/claude/settings.json;
    force = true;
  };

  home.file.".cursor/cli-config.json" = {
    source = ./resources/cursor/cli-config.json;
    force = true;
  };

  xdg.configFile."herdr/config.toml" = {
    source = ./resources/herdr/config.toml;
    force = true;
  };

  xdg.configFile."opencode/AGENTS.md" = {
    source = ./resources/opencode/AGENTS.md;
    force = true;
  };

  xdg.configFile."opencode/opencode.json" = {
    source = ./resources/opencode/opencode.json;
    force = true;
  };
}
