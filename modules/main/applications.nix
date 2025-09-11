# modules/applications.nix

{ config, lib, pkgs, ... }: {

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Import unstable channel -- MOVED! 
  # See main flake.nix & modules/applications.nix
  # nixpkgs.config.packageOverrides = pkgs: {
  #   unstable = import <nixos-unstable> {config = pkgs.config;};
  # };

  environment = {
    systemPackages = with pkgs; [
      

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

      # Wayland / Hyprland apps
      # grim          # Screenshots
      # slurp         # Screen selection for screenshots
      # waybar        # Status bar (optional)
      # wl-clipboard  # Clipboard for Wayland
      # wofi          # Application launcher

      # Input device tools
      keymapp # For ZSA Voyager configuration
      libinput # For trackpad debugging
      libinput-gestures
      solaar # For Logitech devices

    ] ++ (with pkgs.unstable; [
      # R tools
      R
      quarto
    ]);

    variables = {};
  };

}