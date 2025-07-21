{ inputs, lib, config, pkgs, ... }: {
   imports = [ ./nvidia.nix ./niri/nixos.nix];

  environment.sessionVariables.DISPLAY = ":0";
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [
    font-awesome
    helvetica-neue-lt-std
  ];

  xdg.portal.config = {
    common = {
      default = [ "gtk" ];
    };
    obs-studio = {
      default = [ "gnome" ];
    };
  };

  environment.systemPackages = with pkgs; [
    glib
    glxinfo
    networkmanagerapplet
    openzone-cursors
    pwvucontrol
    pcmanfm
    pop-gtk-theme
    pop-icon-theme
    roboto-mono
    xdg-desktop-portal-gnome
    xdg-utils
    wev
    wl-clipboard
    wlr-randr
    xorg.xeyes
  ];

  programs.light.enable = true;
  security.polkit.enable = true;
}
