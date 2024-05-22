{ inputs, lib, config, pkgs, ... }: {
  xdg.configFile."fish/functions/screenshot.fish".source =
    ./resources/screenshot.fish;
  xdg.configFile."sway/config".source = ./resources/sway.config;
  xdg.configFile."waybar/config".source = ./resources/waybar/config;
  xdg.configFile."waybar/style.css".source = ./resources/waybar/style.css;

  home.file.".icons/OpenZone_Black".source =
    "${pkgs.openzone-cursors}/share/icons/OpenZone_Black";

  gtk = {
    enable = true;
    cursorTheme = { name = "OpenZone_Black"; };
    theme = { name = "Pop"; };
  };
}
