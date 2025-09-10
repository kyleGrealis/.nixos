# modules/hardware.nix

{ config, lib, pkgs, ...}: {

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  hardware = {
    
    # For Magic Trackpad bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # ZSA Voyager keyboard support
    keyboard.zsa.enable = true;
  };

}