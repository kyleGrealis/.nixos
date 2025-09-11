# modules/hardware.nix

{ ... }: {

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ZSA Voyager keyboard support
  hardware.keyboard.zsa.enable = true;

}