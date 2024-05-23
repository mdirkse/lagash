{ inputs, lib, config, pkgs, ... }: {
  home.file.".icons/OpenZone_Black".source = "${pkgs.openzone-cursors}/share/icons/OpenZone_Black";

  gtk = {
    enable = true;
    cursorTheme = { name = "OpenZone_Black"; };
    theme = { name = "Pop"; };
  };

  xdg.configFile."fish/functions/screenshot.fish".source = ./resources/screenshot.fish;
  xdg.configFile."kanshi/config".source = ./resources/kanshi.config;
  xdg.configFile."sway/config".source = ./resources/sway.config;
  xdg.configFile."waybar/config".source = ./resources/waybar/config;
  xdg.configFile."waybar/style.css".source = ./resources/waybar/style.css;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = ["google-chrome.desktop"];
      "text/html" = ["google-chrome.desktop"];
      "x-scheme-handler/about" = ["google-chrome.desktop"];
      "x-scheme-handler/http" = ["google-chrome.desktop"];
      "x-scheme-handler/https" = ["google-chrome.desktop"];
      "x-scheme-handler/mailto" = ["google-chrome.desktop"];
      "x-scheme-handler/unknown" = ["google-chrome.desktop"];
      "x-scheme-handler/webcal" = ["google-chrome.desktop"];
    };
  };
}
