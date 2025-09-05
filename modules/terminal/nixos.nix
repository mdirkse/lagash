{ inputs, lib, config, pkgs, ... }: {
  environment.defaultPackages = lib.mkForce [];

  environment.systemPackages = with pkgs; [
    bandwhich
    bash
    bat
    btop
    curl
    delta
    dig
    dmidecode
    dnspeep
    dosfstools
    du-dust
    eza
    file
    gettext
    iputils
    isd
    kitty
    lld
    lsb-release
    lsof
    nano
    netcat
    networkmanager-openconnect
    nixfmt-classic
    nmap
    openconnect
    pciutils
    powertop
    procs
    pstree
    pv
    ripgrep
    unzip
    usbutils
    wget
    yazi
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
    top = "btop";
  };
}
