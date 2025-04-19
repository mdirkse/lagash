{ inputs, lib, config, pkgs, ... }: {
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  environment.systemPackages = with pkgs; [
    grim
    slurp
  ];
}
