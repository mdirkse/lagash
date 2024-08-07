{ inputs, lib, config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bandwhich
    bash
    bat
    curl
    difftastic
    dig
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
    networkmanager-openconnect
    nixfmt-classic
    nmap
    openconnect
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
    g = "git";
    ikat = "kitty +kitten icat";
    ll = "eza -la";
    ls = "eza";
    nix-shell = "nix-shell --command (which fish)";
    ps = "procs";
    rg = "rg --hidden --no-ignore";
    rgrep = "rg";
    ssh = "kitty +kitten ssh";
  };
}
