# modules/services.nix

{ ... }: {

  # Enable the OpenSSH daemon - allows remote SSH connections TO this machine
  services.openssh.enable = true;

  # Start the SSH agent - manages SSH keys for outgoing connections FROM this machine
  programs.ssh.startAgent = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Flatpaks
  services.flatpak.enable = true;

  # Enable sound with pipewire'.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ZSA Voyager keyboard support
  hardware.keyboard.zsa.enable = true;

}