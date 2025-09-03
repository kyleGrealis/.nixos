{
  description = "Kyle's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:

    let
      lib = nixpkgs.lib;
    in {

    nixosConfigurations = {
      nixos = lib.nixosSystem {
        system = "x86_64_linux";
        modules = [ ./configuration.nix ];
      };
    };
  };
}
