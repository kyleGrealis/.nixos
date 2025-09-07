{ config, lib, pkgs, ...}:
let gitcheck = pkgs.writeShellScriptBin "gitcheck" ''
  #!/usr/bin/env bash

  #=================================================================
  # Scan Dev Folder for Git Status
  # Purpose: Scan ~/dev for git repos and show status
  # Author: Kyle Grealis
  # Date: September 7, 2025
  #=================================================================

  DEV_DIR="$HOME/dev"

  # Color codes
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  GREEN='\033[0;32m'
  NC='\033[0m' # No color

  echo -e "\n🔍 Checking git repos in $DEV_DIR...\n"

  # Loop through immediate subdirectories
  for dir in "$DEV_DIR"/*/; do
      # Skip if not a git repo
      if [[ ! -d "$dir/.git" ]]; then
          continue
      fi
      
      cd "$dir" || continue
      repo_name=$(basename "$dir")

      # Check status
      status=$(git status --porcelain)
      branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

      if [[ -z "$status" ]]; then
          echo -e "''${GREEN}✔ $repo_name''${NC} [$branch] — clean"
      else
          echo -e "''${RED}✗ $repo_name''${NC} [$branch] — changes detected:"
          git status -s
          echo
      fi
  done

  echo -e "✅ Done.\n"
'';
in 
{
  home.packages = [ gitcheck ];
}
