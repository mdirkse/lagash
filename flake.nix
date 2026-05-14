{
  description = "Maarten's Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      home-manager,
      microvm,
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      nixModules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        { home-manager.users.maarten = import ./home.nix; }
      ];

    in
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          modules = [
            ./hardware/laptop.nix
            ./modules/system-laptop/nixos.nix
            microvm.nixosModules.host
          ] ++ nixModules;
        };
        vm = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          modules = [
            ./hardware/vm.nix
          ] ++ nixModules;
        };
      };
    };
}
