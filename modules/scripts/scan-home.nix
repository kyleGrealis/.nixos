{ pkgs }:
let 
  scan-home = pkgs.writeShellScriptBin "scan-home" ''
    #!/usr/bin/env bash

    #=================================================================
    # Scan Home Network
    # Purpose: Simple script to scan home network for devices
    # Author: Kyle Grealis
    # Date: September 7, 2025
    #=================================================================

    scan="sudo nmap -sn 192.168.1.0/24"

    #if [[ "$1" == "-y" ]]; then
      $scan | grep "scan report";
    #else
    #	$scan
    #fi
  '';
in 
[ scan-home ]
