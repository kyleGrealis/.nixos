# ./modules/home-manager/default.nix

{ config, ...}: {
  imports = [
    # Application-specific
    ./apps/hyprland.nix
    ./apps/kitty.nix

    # Scripts
    ./bin/backup-dev.nix
    ./bin/gitcheck.nix
    ./bin/rebuild.nix
    ./bin/scan-home.nix
    ./bin/vpn-status.nix
  ];
}