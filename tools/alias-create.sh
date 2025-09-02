#!/bin/bash

set -eu

link_path="${1:-$HOME/.config/git/config.d/alias.conf}"

mkdir -p "$(dirname "$link_path")"
ln -sf "$(pwd)/alias.conf" "$link_path"

if ! git config --global --get-all include.path | grep -Fxq "$link_path"; then
    git config --global --add include.path "$link_path"
fi

echo "Done!"
