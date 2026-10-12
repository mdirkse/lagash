{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    jetbrains-toolbox
    meld
    postman
  ];
}
