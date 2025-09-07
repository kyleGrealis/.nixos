{ config, lib, pkgs, ...}:
let
  backup-dev = pkgs.writeShellScriptBin "backup-dev" ''
    #!/usr/bin/env bash

    #=================================================================
    # Backup Dev Folder Script
    # Purpose: Sync $HOME/dev to piCloud backup location
    # Author: Kyle Grealis
    # Date: September 7, 2025
    #=================================================================

    SOURCE_DIR="$HOME/dev/"
    BACKUP_DIR="$HOME/piCloud/kyle-backup/dev/"

    echo "🔄 Syncing dev folder to piCloud backup..."
    echo "Source: $SOURCE_DIR"
    echo "Target: $BACKUP_DIR"

    # Check if piCloud is mounted
    if [ ! -d "$HOME/piCloud" ]; then
        echo "❌ ERROR: piCloud not mounted at $HOME/piCloud"
        echo "Try: sudo mount -a"
        exit 1
    fi

    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"

    # Rsync with archive mode, human-readable progress, and delete files that no longer exist in source
    rsync -aH --delete --copy-unsafe-links --info=progress2 "$SOURCE_DIR" "$BACKUP_DIR"

    if [ $? -eq 0 ]; then
        echo "✅ Dev folder backup completed successfully!"
        echo "📊 Backup location: $BACKUP_DIR"
    else
        echo "❌ Backup failed with exit code $?"
        exit 1
    fi
  '';
in
{
  home.packages = [ backup-dev ];
}