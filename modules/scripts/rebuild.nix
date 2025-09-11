{ pkgs }:
let 
  rebuild = pkgs.writeShellScriptBin "rebuild" ''
    #!/usr/bin/env bash

    #=================================================================
    # Rebuild NixOS Flake
    # Purpose: Simplify build commands & if build has errors
    # Author: Kyle Grealis
    # Date: September 7, 2025
    #
    # Adapted from No Boilerplate's YouTube video
    # NixOS: Everything Everywhere All at Once
    # https://youtu.be/CwfKlX3rA6E?si=qu6iWnelnLlD1HuN&t=477
    #=================================================================

    set -e

    # Change to the configuration directory
    pushd "$HOME/.nixos" >/dev/null

    # See git changes
    git diff -U0 *.nix

    # Try to rebuild -or- output cleaned error message and exit
    echo "Rebuilding NixOS..."
    sudo nixos-rebuild switch --flake . 2> error.log \
      && echo "✅ Rebuild complete" || (
      echo "❌ Build failed! Error details:"
      echo "================================"
      # Show the last 5 lines which usually contain the actual error
      grep --color error error.log | bat
      echo "================================"
      echo "Full log saved to: error.log"
      exit 1
    )
    
    echo "Rebuilding NixOS Home Manager..."
    home-manager switch --flake . 2> error.log \
      && echo "✅ Home Manager rebuild complete" || (
      echo "❌ Home Manager build failed! Error details:"
      echo "================================"
      # Show the last 5 lines which usually contain the actual error
      grep --color error error.log | bat
      echo "================================"
      echo "Full log saved to: error.log"
      exit 1
    )

    # Return to original directory
    popd >/dev/null
  '';
in 
[ rebuild ]
