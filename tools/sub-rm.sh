#!/bin/bash

set -eu

target_dir="${1:-$HOME/.local/bin}"

for f in subcommands/*.sh; do
    name="$(basename "$f" .sh)"
    link_name="git-$name"
    link_path="$target_dir/$link_name"

    if [ -L "$link_path" ]; then
        rm -f "$link_path"
        echo "Removed symlink: $link_path"
    else
        echo "No symlink to remove: $link_path"
    fi
done

echo "Done!"
