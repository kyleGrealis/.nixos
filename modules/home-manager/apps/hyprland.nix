# ./modules/home-manager/apps/hyprland.nix

{ config, lib, ...}: {
  programs.kitty.enable = true;
  wayland.windowManager.hyprland.enable = true;
}