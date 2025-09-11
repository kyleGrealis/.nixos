# modules/packages.nix

{ pkgs, ... }: {

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nixpkgs.config.packageOverrides = pkgs: {
  #   unstable = import <nixos-unstable> {config = pkgs.config;};
  # };

  environment = {
    systemPackages = with pkgs; [
      
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

      # Desktop applications
      ardour
      (brave.override {
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation"
          "--ozone-platform=wayland"
        ];
      })
      calibre
      discord
      gedit
      gimp3-with-plugins
      github-desktop
      gparted
      gpu-viewer
      kitty
      libreoffice
      nextcloud-client
      obs-studio
      positron-bin
      rstudio
      slack
      spotify
      thunderbird
      vlc
      zoom-us

      # System tools
      adwaita-icon-theme
      pandoc
      texlive.combined.scheme-medium

      # Input device tools
      keymapp # For ZSA Voyager configuration
      libinput # For trackpad debugging
      libinput-gestures
      solaar # For Logitech devices

    ] ++ 
    (with pkgs.unstable; [
      # R tools
      R
      quarto
    ]) ++
    (import ../scripts/backup-dev.nix { inherit pkgs; }) ++
    (import ../scripts/create-nix.nix { inherit pkgs; }) ++
    (import ../scripts/gitcheck.nix { inherit pkgs; }) ++
    (import ../scripts/rebuild.nix { inherit pkgs; }) ++
    (import ../scripts/scan-home.nix { inherit pkgs; }) ++
    (import ../scripts/vpn-status.nix { inherit pkgs; });

  };

}