{ inputs, lib, config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bandwhich
    bash
    bat
    curl
    difftastic
    dmidecode
    dnspeep
    dosfstools
    du-dust
    eza
    file
    iputils
    kitty
    lld
    lsof
    nano
    netcat
    nixfmt-classic
    nmap
    powertop
    procs
    pstree
    pv
    ripgrep
    rustup
    unzip
    usbutils
    wget
    zip
  ];

  programs.fish.enable = true;
  programs.fish.interactiveShellInit = "fish_add_path $HOME/bin";

  programs.fish.shellAliases = {
    cat = "bat";
    du = "dust";
    ikat = "kitty +kitten icat";
    ll = "eza -la";
    ls = "eza";
    ps = "procs";
    rg = "rg --hidden --no-ignore";
    rgrep = "rg";
    ssh = "kitty +kitten ssh";
  };
}
