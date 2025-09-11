# ./modules/home-manager/default.nix

{ config, ...}: {
  imports = [
    # Application-specific
    ./apps/kitty.nix

  ];
}