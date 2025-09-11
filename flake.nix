{
  description = "Kyle's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }: 
  
  let
    system = "x86_64-linux";
    
    overlay-unstable = final: prev: {
      # unstable = nixpkgs-unstable.legacyPackages.${prev.system};  # not for Unfree
      # Using this variant since unfree packages are needed
      # https://nixos.wiki/wiki/Flakes#Importing_packages_from_multiple_channels
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };

    # Create an overlay to disable Tailscale tests
    overlay-tailscale = final: prev: {
      tailscale = prev.tailscale.overrideAttrs (oldAttrs: {
        doCheck = false; # Disable the failing tests
      });
    };

    pkgs = nixpkgs-unstable.legacyPackages.${system};

  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {

      inherit system;
      modules = [

        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [
            overlay-unstable
            # Apply the overlay to disable Tailscale tests
            overlay-tailscale
          ];
        })

        ./configuration.nix

        ./modules/main/desktop.nix
        ./modules/main/networking.nix
        ./modules/main/nvidia.nix
        ./modules/main/packages.nix
        ./modules/main/services.nix
        ./modules/main/tailscale.nix
        ./modules/main/user.nix
        
      ];
    };

    homeConfigurations = {
      kyle = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
  };
}
