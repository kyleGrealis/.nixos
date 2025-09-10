# modules/services.nix

{ config, lib, pkgs, ... }: {

  # Enable the OpenSSH daemon - allows remote SSH connections TO this machine
  services.openssh.enable = true;

  # Start the SSH agent - manages SSH keys for outgoing connections FROM this machine
  programs.ssh.startAgent = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.flatpak.enable = true;

}