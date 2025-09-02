#!/bin/bash

set -eu

target_dir="${1:-$HOME/.local/bin}"
broken_links=$(find "$target_dir" -xtype l -name 'git-*')

if [ -z "$broken_links" ]; then
    echo "No broken symlinks found in $target_dir."
    exit 0
fi

echo "Removing broken symlinks in $target_dir..."
echo "$broken_links"

find "$target_dir" -xtype l -name 'git-*' -delete

echo "Done!"
