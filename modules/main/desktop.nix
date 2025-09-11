# modules/desktop.nix

{ config, lib, pkgs, ... }: {

  services.xserver = {

    # Enable the X11 windowing system.
    enable = true;
  
    # Enable the GNOME Desktop Environment
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Essential for Hyprland
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # # Essential services for Wayland/Hyprland
  # services.xserver.displayManager.gdm.wayland = true;
  
  # # Portal for screensharing, etc.
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-gtk
  #   ];
  # };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      font-awesome
      fira-code
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["FiraCode Nerd Font" "Fira Code"];
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
      };
    };
  };

}