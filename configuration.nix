# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: let
  tailscale-home = pkgs.writeShellScriptBin "tailscale-home" ''
    echo "🏠 Switching to home mode..."
    /run/wrappers/bin/sudo ${pkgs.tailscale}/bin/tailscale up --exit-node=""

    # Verification logic
    STATUS=$(${pkgs.tailscale}/bin/tailscale status)
    if echo "$STATUS" | grep -q "offers exit node"; then
      echo "✅ Exit node protection enabled! Traffic now routes normally."
    else
      echo "❌ Something went wrong. Please check 'tailscale status'."
    fi
  '';

  tailscale-protect = pkgs.writeShellScriptBin "tailscale-protect" ''
     PI5_IP="100.125.173.109"
     echo "🛡️ Switching to protection mode..."
     /run/wrappers/bin/sudo ${pkgs.tailscale}/bin/tailscale up --exit-node=$PI5_IP

     # Verification logic
     STATUS=$(${pkgs.tailscale}/bin/tailscale status)
     if echo "$STATUS" | grep -q "; exit node;"; then
       echo "⚠️  -------------------- WARNING!! ---------------------"
       echo "✅ Exit node protection ENABLED!! All traffic now routes through your Tailnet."
       echo "⚠️  ----------------------------------------------------"
     else
    echo "❌ Something went wrong. Please check tailscale status."
     fi
  '';
in {
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

    # NVIDIA configs from below
    blacklistedKernelModules = ["nouveau"]; # default when using proprietary drivers
    kernelParams = ["nvidia-drm.modeset=1"];
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  #------- [ NVIDIA CONFIGURATION ] -------#
  # Ref: https://wiki.nixos.org/wiki/NVIDIA
  hardware.graphics.enable = true;

  # For offloading, `modesetting` is needed additionally,
  # otherwise the X-server will be running permanently on nvidia,
  # thus keeping the GPU always on (see `nvidia-smi`).
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  hardware.nvidia = {
    open = true;
    # package = config.boot.kernelPackages.nvidiaPackages.stable; # Default
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # boot = {
  #   blacklistedKernelModules = ["nouveau"]; # default when using proprietary drivers
  #   kernelParams = ["nvidia-drm.modeset=1"];
  # };

  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
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
    networkmanager = {
      enable = true;
      dispatcherScripts = [
        {
          source = pkgs.writeText "99-tailscale-autoswitch" ''
            #!/usr/bin/env bash

            INTERFACE=$1
            STATUS=$2

            # Add more known networks, if needed:
            KNOWN_NETS=("Go_Canes" "Canes_guest")

            LOG_FILE="/var/log/tailscale-autoswitch.log"

            log() {
            	echo "$(date): $*" >> "$LOG_FILE"
            }

            log "Network change detected: Interface=$INTERFACE Status=$STATUS"

            # Get wifi interface
            WIFI_INTERFACE=$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE device | grep ":wifi$" | cut -d: -f1)

            # Only act on wifi connections that are activated
            if [ "$STATUS" = "up" ] && [ "$INTERFACE" = "$WIFI_INTERFACE" ]; then
              # Get current SSID
              CURRENT_SSID=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
              log "Connected to SSID: $CURRENT_SSID"

              # Check if network is known
              KNOWN=false
              for NETWORK in "''${KNOWN_NETS[@]}"; do
                  if [ "$CURRENT_SSID" = "$NETWORK" ]; then
                  	KNOWN=true
                  	break
                  fi
              done

              if [ "$KNOWN" = true ]; then
              	log "Home network detected: $CURRENT_SSID. Running home script..."
              	${tailscale-home}/bin/tailscale-home >> "$LOG_FILE" 2>&1
              else
              	log "Unknown network detected: $CURRENT_SSID. Running protect script..."
              	${tailscale-protect}/bin/tailscale-protect >> "$LOG_FILE" 2>&1
              fi
            fi

            exit 0
          '';
          # "basic" is the default. Scripts in /etc/NetworkManager/dispatcher.d will
          # run after wifi connects or disconnects & won't interfere with other
          # networking scripts
          type = "basic";
        }
      ];
    };

    # Firewall configuration for Tailscale:
    firewall = {
      enable = true; # keep firewall enabled for security
      checkReversePath = "loose"; # Required for subnet routing
      trustedInterfaces = ["tailscale0"]; # Trust the Tailscale interface
    };

    # Tailnet IP addresses for Raspberry Pi devices
    extraHosts = ''
      100.125.173.109 pi5
      100.108.174.90  pi4
    '';
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # Allow using exit nodes
  };

  #------- [ MOUNTING piCloud SHARED DRIVE OVER TAILNET ] -------#
  # Mount piCloud over CIFS/SMB:
  fileSystems."/home/kyle/piCloud" = {
    device = "//100.125.173.109/piCloud";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-secrets"
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
    # Create log files for autoswitch:
    "f /var/log/tailscale-autoswitch.log 0644 root root -"
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
      # Terminal essentials
      alejandra
      bash
      bash-completion
      btop
      cifs-utils
      curl
      direnv
      gfortran
      git
      gnumake
      htop
      libgcc
      libxml2
      micro
      fastfetch
      neovim
      nmap
      nix-bash-completions
      nix-prefetch-git
      openssl
      pkg-config-unwrapped
      python3Full
      python312Packages.pip
      ripgrep
      rsync
      samba
      stow
      tldr
      tree
      unzip
      vim
      wget
      xclip
      yazi
      zlib

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
      nvidia-modprobe
      nvtopPackages.full
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
      nodejs
      os-prober
      pandoc
      which

      # R tools
      R
      quarto

      # Input device tools
      keymapp # For ZSA Voyager configuration
      libinput # For trackpad debugging
      libinput-gestures
      solaar # For Logitech devices

      # For NVIDIA
      (writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
      '')

      # For Tailscale autoswitching; can be used outside of auto script
      tailscale-home
      tailscale-protect
    ];

    variables = {};
  };

  #------- [ SERVICES ] -------#
  programs.ssh.startAgent = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire'.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.flatpak.enable = true;

  #------- [ FONT SETTINGS ] -------#
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      font-awesome
      fira-code
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["FiraCode Nerd Font" "Fira Code"];
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
      };
    };
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
  };

  system.stateVersion = "25.05";
}
