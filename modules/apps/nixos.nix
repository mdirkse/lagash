{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  virtualboxWithExtpack = import ./virtualbox-with-extpack.nix { inherit lib pkgs; };
in
{
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
        mechatroner.rainbow-csv
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
    gnome-calculator
    google-chrome
    imagemagick
    prusa-slicer
    slack
    spotify
    tailscale-systray
    vlc
  ];

  programs.chromium.enable = true;
  programs.chromium.extensions = [
    "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1password
    "maccjhjfjhgeacbaenlgghpfnlbgjnep" # clickable google maps
    "bcjindcccaagfpapjjmafapmmgkkhgoa" # jsonformatter
    "blaaajhemilngeeffpbfkdjjoefldkok" # leechblock NG
    "hddnkoipeenegfoeaoibdmnaalmgkpip" # toby
    "ddkjiahejlhfcafbddmgiahcphecmpfh" # ublock origin lite
  ];

  virtualisation.virtualbox.host = {
    addNetworkInterface = false;
    enable = true;
    enableExtensionPack = false;
    enableKvm = true;
    package = virtualboxWithExtpack;
  };
}
