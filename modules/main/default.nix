# ./modules/main/default.nix

{ config, ...}: {
  imports = [
    ./applications.nix
    ./audio.nix
    ./desktop.nix
    ./development.nix
    ./hardware.nix
    ./networking.nix
    ./nvidia.nix
    ./services.nix
    ./tailscale.nix
    ./user.nix
  ];
}