# ./modules/home-manager/apps/hyprland.nix

{ config, lib, pkgs, ...}: 
let
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{

  imports = [
    ./wayland.nix
    ./dbus.nix
  ];

  security = {
    pam.services.login.enableGnomeKeyring = true;
  };

  services.gnome.gnome-keyring.enable = true;

  programs = {
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland = { enable = true; };
      portalPackage = pkgs-hyprland.xdg-desktop-portal-hyprland;
    };
  };

  services.xserver = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
      # theme = "chili";
      package = pkgs.sddm;
    };
  };

}