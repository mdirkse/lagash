{ inputs, lib, config, pkgs, ... }: {
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [
    font-awesome
    helvetica-neue-lt-std
    (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

  environment.systemPackages = with pkgs; [
    grim
    light
    networkmanagerapplet
    pavucontrol
    pcmanfm
    slurp
    swaynotificationcenter
    xdg-utils
    waybar
    wev
    wl-clipboard
    wlogout
    wofi
    xorg.xeyes
  ];

  services.gnome.gnome-keyring.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
}
