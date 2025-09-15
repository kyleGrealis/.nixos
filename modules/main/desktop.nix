# modules/desktop.nix

{ config, lib, pkgs, ... }: 

let
  background-package = pkgs.runCommand "sddm-background" {} ''
    cp ${../../sddm-background.jpg} $out
  '';
in {

  # X11 configuration ----
  # (required even for Wayland-only setups due to SDDM dependency)
  services.xserver = {
    enable = true;
    # Configure keymap (for both X11 & Wayland)
    xkb.layout = "us";
    xkb.variant = "";
  };

  # GNOME ----
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  # Hyprland ----
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Enable SDDM ----
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "chili";
  };

  # Enable background for SDDM theme ---
  environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/chili/theme.conf.user" ''
      [General]
      background=${background-package}
    '')
  ];

  # Optional: Hint Electron apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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