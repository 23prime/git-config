#!/bin/bash

set -eu

target_dir="${1:-$HOME/.local/bin}"

for f in subcommands/*.sh; do
    name="$(basename "$f" .sh)"
    link_name="git-$name"
    link_path="$target_dir/$link_name"
    echo $link_path

    ln -sf "$(pwd)/$f" "$link_path"
    chmod +x "$link_path"

    echo "Created symlink for $name.sh to $link_path"
done

echo "Done!"
