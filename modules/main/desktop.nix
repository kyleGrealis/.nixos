# modules/desktop.nix

{ config, lib, pkgs, ... }: {

  services.xserver = {

    # Enable the X11 windowing system.
    # enable = true;
    enable = false;
  
    # Enable the GNOME Desktop Environment
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # displayManager.sddm.enable = true;

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

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