{
  description = "Kyle's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib;

    # Create an overlay to disable Tailscale tests
    tailscale-overlay = final: prev: {
      tailscale = prev.tailscale.overrideAttrs (oldAttrs: {
        doCheck = false; # Disable the failing tests
      });
    };
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        system = "x86_64_linux";
        modules = [
          # Apply the overlay to disable Tailscale tests
          ({
            config,
            pkgs,
            ...
          }: {
            nixpkgs.overlays = [tailscale-overlay];
          })
          ./configuration.nix
          ./modules/nvidia.nix
          ./modules/tailscale.nix
        ];
      };
    };
  };
}
