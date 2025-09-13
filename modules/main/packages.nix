# modules/packages.nix

{ pkgs, ... }: {

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nixpkgs.config.packageOverrides = pkgs: {
  #   unstable = import <nixos-unstable> {config = pkgs.config;};
  # };

  environment = {
    systemPackages = with pkgs; [
      
      bat
      btop
      cifs-utils
      curl
      git
      htop
      micro
      fastfetch
      nmap
      os-prober
      python3Full
      python312Packages.pip
      ripgrep
      rsync
      samba
      stow
      tealdeer  # faster tldr
      trash-cli
      tree
      unzip
      vim
      wget
      which
      wl-clipboard-rs
      xclip
      yazi

      # Desktop applications
      ardour
      bitwarden-desktop
      (brave.override {
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation"
          "--ozone-platform=wayland"
          # This removes the KDEWallet password thing when opening Brave
          "--password-store=basic"
        ];
      })
      calibre
      discord
      gedit
      gimp3-with-plugins

      gnome-extension-manager
      gnomeExtensions.user-themes

      gparted
      gpu-viewer
      kitty
      libreoffice
      nextcloud-client
      obs-studio
      pavucontrol   # audio
      positron-bin
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
      brightnessctl
      keymapp # For ZSA Voyager configuration
      libinput # For trackpad debugging
      libinput-gestures
      solaar # For Logitech devices

      # Hyprland things
      rofi-wayland
      kdePackages.dolphin
      nwg-displays
      hyprcursor
      cava  # music visualizer
      dunst # notification daemon
      qt6ct
      waybar
      wlogout
      grimblast
      slurp
      jq
      hyprpaper

    ] ++ 
    (with pkgs.unstable; [
      # R tools
      R
      quarto
    ]) ++
    (import ../scripts/backup-dev.nix { inherit pkgs; }) ++
    (import ../scripts/create-nix.nix { inherit pkgs; }) ++
    (import ../scripts/gitcheck.nix { inherit pkgs; }) ++
    # (import ../scripts/rebuild.nix { inherit pkgs; }) ++
    (import ../scripts/scan-home.nix { inherit pkgs; }) ++
    (import ../scripts/vpn-status.nix { inherit pkgs; });

  };

}
