{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  environment.defaultPackages = lib.mkForce [ ];

  environment.systemPackages = with pkgs; [
    bandwhich
    bash
    bat
    btop
    curl
    cyme
    delta
    dig
    dmidecode
    dnspeep
    dosfstools
    dust
    eza
    file
    gettext
    iputils
    isd
    kitty
    lld
    lsb-release
    lsof
    micro
    netcat
    networkmanager-openconnect
    net-tools
    nixfmt
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

  programs.fish.shellAbbrs = {
    cdj = "cd ~/Work/jumbo";
  };

  programs.fish.shellAliases = {
    cat = "bat";
    du = "dust";
    ikat = "kitty +kitten icat";
    ll = "eza -la";
    ls = "eza";
    lsusb = "cyme";
    nano = "micro";
    nix-shell = "nix-shell --command (which fish)";
    ps = "procs";
    rg = "rg --hidden --no-ignore";
    rgrep = "rg";
    ssh = "kitty +kitten ssh";
    top = "btop";
  };

  security.sudo.extraRules = [
    {
      users = [ "maarten" ];
      commands = [
        {
          command = "ALL";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];

  users.users = {
    maarten = {
      extraGroups = [
        "docker"
        "libvirtd"
        "vboxusers"
        "video"
        "wheel"
      ];
      initialPassword = "paratodostodo";
      isNormalUser = true;
      shell = pkgs.fish;
    };
  };
}
