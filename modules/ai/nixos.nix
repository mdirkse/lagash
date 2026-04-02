{ inputs, lib, config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    beads
    claude-code
    cursor-cli
    opencode
  ];
}
