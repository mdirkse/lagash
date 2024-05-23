{ inputs, lib, config, pkgs, ... }: {
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [
    font-awesome
    helvetica-neue-lt-std
    (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

  environment.systemPackages = with pkgs; [
    glib
    grim
    kanshi
    networkmanagerapplet
    openzone-cursors
    pavucontrol
    pcmanfm
    pop-gtk-theme
    pop-icon-theme
    slurp
    swaynotificationcenter
    xdg-utils
    waybar
    wev
    wl-clipboard
    wlogout
    wlr-randr
    wofi
    xorg.xeyes
  ];

  programs.light.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.gnome.gnome-keyring.enable = true;
}
