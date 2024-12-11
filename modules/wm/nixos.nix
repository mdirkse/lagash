{ inputs, lib, config, pkgs, ... }: {
   imports = [ ./nvidia.nix ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [
    font-awesome
    helvetica-neue-lt-std
  ];

  environment.systemPackages = with pkgs; [
    glib
    glxinfo
    grim
    kanshi
    networkmanagerapplet
    openzone-cursors
    pavucontrol
    pcmanfm
    pop-gtk-theme
    pop-icon-theme
    roboto-mono
    slurp
    swaynotificationcenter
    xdg-utils
    waybar
    wev
    winetricks
    wineWowPackages.stable
    wineWowPackages.waylandFull
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
  security.polkit.enable = true;
}
