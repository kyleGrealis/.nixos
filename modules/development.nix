# modules/development.nix
# This module is geared more at terminal tools & build essentials

{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bash
    bash-completion
    bat
    btop
    cifs-utils
    curl
    direnv
    gfortran
    git
    gnumake
    htop
    libgcc
    libxml2
    micro
    fastfetch
    nmap
    nix-bash-completions
    nix-prefetch-git
    nodejs
    openssl
    os-prober
    pkg-config-unwrapped
    python3Full
    python312Packages.pip
    ripgrep
    rsync
    samba
    stow
    tealdeer  # faster tldr
    tree
    unzip
    vim
    wget
    which
    xclip
    yazi
    zlib
  ];
}