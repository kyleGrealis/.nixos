{
  config,
  lib,
  pkgs,
  ...
}: let
  # Tailscale home mode script
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

  # Tailscale protect mode script
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
  # Tailscale service configuration
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Add PATH to NetworkManager-dispatcher service
  systemd.services.NetworkManager-dispatcher.path = [
    pkgs.networkmanager    # for nmcli
    pkgs.tailscale        # for tailscale
    pkgs.coreutils        # for basic commands
    pkgs.bash             # for shell commands
  ];

  # Firewall configuration for Tailscale
  networking = {
    firewall = {
      trustedInterfaces = ["tailscale0"];
      checkReversePath = "loose";
    };

    # Tailnet IP addresses for Raspberry Pi devices
    extraHosts = ''
      100.125.173.109 pi5
      100.108.174.90  pi4
    '';

    networkmanager = {
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
          type = "basic";
        }
      ];
    };
  };

  # Custom tailscale switching scripts
  environment.systemPackages = [
    tailscale-home
    tailscale-protect
  ];

  # Create log files for autoswitch
  systemd.tmpfiles.rules = [
    "f /var/log/tailscale-autoswitch.log 0644 root root -"
  ];
}
