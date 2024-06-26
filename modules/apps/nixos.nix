{ inputs, lib, config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        coolbear.systemd-unit-file
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        github.copilot
        github.copilot-chat
        github.vscode-github-actions
        hashicorp.terraform
        ms-azuretools.vscode-docker
        shardulm94.trailing-spaces
        skyapps.fish-vscode
        svelte.svelte-vscode
        timonwong.shellcheck
        tyriar.sort-lines
        vue.volar
      ];
    })
    gimp
    gnome.gnome-calculator
    google-chrome
    imagemagick
    prusa-slicer
    rawtherapee
    slack
    spotify
    tailscale-systray
    #virtualboxExtpack
  ];

  programs.chromium.enable = true;
  programs.chromium.extensions = [
    "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1password
    "ollmdedpknmlcdmpehclmgbogpifahdc" # fobusmode
    "bcjindcccaagfpapjjmafapmmgkkhgoa" # jsonformatter
    "chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
    "hddnkoipeenegfoeaoibdmnaalmgkpip" # toby
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
  ];

  virtualisation.virtualbox.host.enable = true;
}
