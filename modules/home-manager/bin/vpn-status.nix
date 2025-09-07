{ config, lib, pkgs, ...}:
let 
  vpn-status = pkgs.writeShellScriptBin "vpn-status" ''
    #/usr/bin/env bash

    #=================================================================
    # Check VPN Status
    # Purpose: Check VPN status and output information regarding location
    # Author: Kyle Grealis
    # Date: September 7, 2025
    #=================================================================

    echo "🌐 Checking network routing status..."

    # Get location and IP info
    IP=$(curl -s https://ipinfo.io/ip)
    CITY=$(curl -s https://ipinfo.io/city)
    REGION=$(curl -s https://ipinfo.io/region)
    ISP=$(curl -s https://ipinfo.io/org)

    echo "🌍 Your IP: $IP"
    echo "📍 Location: $CITY, $REGION"
    echo "🏢 ISP: $ISP"

    # Check if in Dallas, TX (your home location)
    if [[ "$CITY" == "Dallas" && "$REGION" == "Texas" ]]; then
      echo "✅ Traffic is routing through Dallas, TX (home)! 🏠"
      
      # Check if using exit node
      if tailscale status 2>/dev/null | grep -q "; exit node;"; then
        echo "🛡️ Exit node ACTIVE - all traffic protected through Tailnet."
      else
        echo "🏠 You appear to be on your home network directly."
      fi
    else
      echo "❌ NOT routing through Dallas, TX!"
      echo "⚠️ Your connection may be exposed on current network."
      
      # Suggest enabling exit node
      echo "💡 Tip: Run 'tailscale-protect.sh' to route through home."
    fi
  '';
in 
{
  home.packages = [ vpn-status ];
}
