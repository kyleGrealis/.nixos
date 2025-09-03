# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  #------- [ BOOT OPTIONS ] -------#
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

  #------- [ DESKTOP / MAIN ] -------#
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kyle = {
    isNormalUser = true;
    description = "Kyle";
    extraGroups = ["networkmanager" "wheel" "input"];
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  #------- [ SET UP EXTERNALS ] -------#
  # For Magic Trackpad bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ZSA Voyager keyboard support
  hardware.keyboard.zsa.enable = true;

  #------- [ NETWORKING ] -------#
  services.openssh.enable = true;

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  #------- [ MOUNTING piCloud SHARED DRIVE OVER TAILNET ] -------#
  # Mount piCloud over CIFS/SMB:
  fileSystems."/home/kyle/piCloud" = {
    device = "//100.125.173.109/piCloud";
    fsType = "cifs";
    options = [
      "credentials=/home/kyle/.nixos/smb-secrets"
      "uid=1000"
      "gid=1000"
      "vers=3.0"
      "nofail" # Don't fail boot if mount fails
      "_netdev" # Mark as a network device
      "x-systemd.automount" # Automount on access
      "x-systemd.requires=tailscaled.service"
      "x-systemd.requires=network-online.target"

      # timing delays to prevent boot or shutdown hanging:
      "x-systemd.idle-timeout=300" # 5 minutes of inactivity
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
    ];
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  #------- [ RULES ] -------#
  systemd.tmpfiles.rules = [
    "d /home/kyle/piCloud 0755 kyle users -"
  ];

  #------- [ PACKAGES ] -------#
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Import unstable channel
  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import <nixos-unstable> {config = pkgs.config;};
  };

  environment = {
    systemPackages = with pkgs; [
      

      # Desktop applications
      ardour
      (brave.override {
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation"
          "--ozone-platform=wayland"
        ];
      })
      calibre
      discord
      gedit
      gimp3-with-plugins
      github-desktop
      gparted
      gpu-viewer
      kitty
      libreoffice
      nextcloud-client
      obs-studio
      positron-bin
      rstudio
      slack
      spotify
      thunderbird
      vlc
      zoom-us

      # System tools
      adwaita-icon-theme
      pandoc

      # R tools
      R
      quarto

      # Input device tools
      keymapp # For ZSA Voyager configuration
      libinput # For trackpad debugging
      libinput-gestures
      solaar # For Logitech devices
    ];

    variables = {};
  };

  #------- [ SERVICES ] -------#
  programs.ssh.startAgent = true;
  programs.direnv.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.flatpak.enable = true;


  nix.settings = {
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
  };

  system.stateVersion = "25.05";
}
