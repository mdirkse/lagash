{
  inputs,
  lib,
  config,
  options,
  pkgs,
  ...
}:
{
  # You can import other NixOS modules here
  imports = [
    ./machine.nix
    ./nix.nix
  ];
}
