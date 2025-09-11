{ config, pkgs, inputs, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        fontSize = 32;
      };
    };
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
  };

  system.stateVersion = "25.05";
  
}
