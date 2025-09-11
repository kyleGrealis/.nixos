{ config, lib, pkgs, ...}:
let 
  create-nix = pkgs.writeShellScriptBin "create-nix" ''
    #!/usr/bin/env bash

    #=================================================================
    # Create a R & Positron Nix development environment
    # Purpose: Quickly scaffold a reproducible flake for R projects.
    # Author: Kyle Grealis
    # Date: September 11, 2025
    #=================================================================

    set -euo pipefail

    if [ -f flake.nix ]; then
      echo "❌ flake.nix already exists here."
      exit 1
    fi

    cat > flake.nix <<EOF
{
  description = "R Data Science Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # For Positron
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            positron-bin
            quarto
            R
            # for LaTeX:
            texlive.combined.scheme-medium
            pkgs.tectonic
          ]  ++
          
          (with pkgs.rPackages; [
            devtools
            froggeR
            fs
            glue
            here
            quarto
            tidyverse
            
            # add others below here...
          ]);

          shellHook = '''
            echo "📊 $(basename $PWD) R & Quarto Environment Ready"
          ''';
        };
      });
}
EOF

      echo "✅ Created flake.nix"
  '';
in {
  home.packages = [ create-nix ];
}