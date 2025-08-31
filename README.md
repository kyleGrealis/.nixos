# NixOS Configurations

Keeping up with my configuration edits & adding good version control.

This script was adapted from No Boilerplate's [YouTube video "NixOS: Everything Everywhere All at Once"](https://www.youtube.com/watch?v=CwfKlX3rA6E&list=PL6lSNj91S1u7LL7PEIxoGuyeCkkDWcn8z&index=3):

```
#!/usr/bin/env bash

set -e
pushd /home/kyle/dev/nixos/

# Modify the config file
micro $HOME/dev/nixos/configuration.nix

# alejandra is a Nix code formatter for styling
alejandra . &>/dev/null

# Show only the changed lines themselves
git diff -U0 *.nix
echo "NixOS rebuilding..."

# Try to rebuild -or- output cleaned error message and exit
sudo nixos-rebuild switch &>nixos-switch.log || (
	cat nixos-switch.log | grep --color error && false
)

# Write commit message
gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"

# Return to original directory
popd

# Refresh shell environment to prevent hashing interference with new $PATH variables
# Issue: immediately running `which {newPkg}` wouldn't find the newly-installed {newPkg}
echo "Refreshing shell environment..."
exec bash
```
