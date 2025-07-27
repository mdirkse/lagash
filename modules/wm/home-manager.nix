{ inputs, lib, config, pkgs, ... }:
let
  wm_target = "graphical-session.target";
in {
  imports = [ niri/home-manager.nix ];

  home.file.".icons/OpenZone_Black".source = "${pkgs.openzone-cursors}/share/icons/OpenZone_Black";

  gtk = {
    enable = true;
    cursorTheme = { name = "OpenZone_Black"; };
    iconTheme = {
      package = pkgs.pop-icon-theme;
      name = "pop-icon-theme";
    };
    theme = { name = "Pop"; };
  };

  xdg.configFile."kanshi/config".source = ./resources/kanshi.config;
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

  programs = {
    swaylock.enable = true;
    waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = wm_target;
      };
    };
    wlogout.enable = true;
    wofi.enable = true;
  };

  services = {
    blueman-applet.enable = true;
    gnome-keyring.enable = true;
    kanshi = {
      enable = true;
      systemdTarget = wm_target;
    };
    network-manager-applet.enable = true;
    swayidle = {
      enable = true;
      systemdTarget = wm_target;
      events = [ { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f --color 000000"; } ];
    };
    swaync.enable = true;
    trayscale.enable = false;
  };

  systemd.user.services = {
    swaybg = {
      Install = {
        WantedBy = [ wm_target ];
      };
      Unit = {
        After = [ wm_target ];
        Description = "Wayland background";
      };

      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg --image ${config.home.homeDirectory}/Pictures/wallpaper/kizlar-ve-kedi.jpg --mode fill";
        Restart = "on-failure";
      };
    };
    xwayland-satellite = {
      Install = {
        WantedBy = [ wm_target ];
      };
      Unit = {
        After = [ wm_target ];
        Description = "XWayland satellite";
      };

      Service = {
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
        Restart = "on-failure";
      };
    };
  };
}
